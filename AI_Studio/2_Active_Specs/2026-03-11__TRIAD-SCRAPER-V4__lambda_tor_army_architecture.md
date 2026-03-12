# TRIAD-SCRAPER-V4: Lambda Tor Army Architecture

**Author**: Antigravity (architectural direction) + Claude Code (formalization)
**Date**: 2026-03-11
**Status**: SPEC READY FOR IMPLEMENTATION
**Predecessor**: `wago/scraper_v3.py` (Tor Army v3 — Async Swarm Scraper)

---

## Problem Statement

Tor Army v3 uses 400 Tor instances for IP diversity when scraping Wowhead. However, Cloudflare maintains a list of every public Tor exit node and assigns them rock-bottom trust scores. Even with perfect TLS fingerprinting via `curl_cffi`, the IP origin itself triggers WAF blocks. Estimated WAF block rate: 60-70%, causing massive queue recycling and multi-day scrape times.

## Architectural Direction (from Antigravity)

Replace Tor as the primary IP source with **AWS Lambda** serverless invocations. Each Lambda invocation gets a random AWS datacenter IP. While WAFs know these are AWS IPs, AWS is so integrated into the internet backbone that WAFs are significantly more lenient on them compared to Tor exit nodes.

Keep Tor as a fallback layer.

## Solution: Lambda Tor Army v4

### Architecture — Three Layers

1. **Local Orchestrator** (`scraper_v4.py`)
   - Runs on local machine (Ryzen 9 9950X3D, 128GB RAM)
   - Manages the work queue (same PriorityQueue design as v3)
   - Fans out work items to Lambda invocations via boto3 async
   - Collects results, writes parsed JSON + gzipped HTML to local disk
   - Live dashboard (same stats tracker as v3)
   - Falls back to Tor fleet if Lambda rate-limited

2. **Lambda Worker** (`lambda_scraper/handler.py`)
   - Packaged as Lambda function with `curl_cffi` **Lambda Layer** (see Deployment Complexity below)
   - Receives: target type, entity ID, URL pattern
   - Performs: single HTTP GET with browser fingerprint impersonation
   - Returns: gzip-compressed HTML + status code + metadata (compressed to stay under 6MB payload limit)
   - Parsing stays LOCAL (orchestrator side) — Lambda just fetches
   - Memory: 256MB (128MB insufficient for curl_cffi native libs), Timeout: 30s
   - Runtime: Python 3.12+ (Lambda supports up to 3.13)
   - **Payload safety**: Lambda synchronous response limit is 6MB. Wowhead pages average ~200KB but outliers can reach 1-2MB. Response is gzip-compressed in Lambda before return. If a compressed page still exceeds 6MB (extremely unlikely), Lambda writes to S3 and returns the key instead

3. **Tor Fallback** (existing TorFleet from v3)
   - Used when Lambda returns rate-limit signals
   - Optimized torrc with Antigravity's fix: `ExitNodes {us},{ca},{gb},{de}` (whitelist, not blacklist)
   - Same CircuitManager + async worker design

### DB2 Pre-Filtering (Mandatory)

Before generating ANY ID list, query wago-db2 to get only IDs that actually exist. This is a 35-40% reduction in total requests.

**Verified counts (build 66263):**

| Entity | URL Pattern | DB2 Table | Valid IDs |
|--------|-------------|-----------|-----------|
| Spells | `/spell=` | SpellName | 400,101 |
| Items | `/item=` | ItemSparse | 170,130 |
| Quests | `/quest=` | QuestV2 | 65,187 |
| GameObjects | `/object=` | GameObjects | 29,025 |
| NPCs | `/npc=` | Creature | 22,747 |
| Achievements | `/achievement=` | Achievement | 13,622 |
| Transmog Sets | `/transmog-set=` | TransmogSet | 4,883 |
| Battle Pets | `/npc=` (pet) | BattlePetSpecies | 2,936 | *subset of NPCs* |
| Garrison Missions | `/mission=` | GarrMission | 1,757 |
| Quest Lines | `/questline=` | QuestLine | 1,640 |
| Mounts | `/mount=` | Mount | 1,598 |
| Currencies | `/currency=` | CurrencyTypes | 1,449 |
| Flight Paths | `/taxinode=` | TaxiNodes | 1,449 |
| Maps/Zones | `/zone=` | Map | 1,166 |
| Journal Encounters | boss pages | JournalEncounter | 1,147 |
| Toys | `/item=` (toy) | Toy | 1,130 | *subset of Items* |
| Garrison Followers | `/follower=` | GarrFollower | 1,053 |
| Item Sets | `/item-set=` | ItemSet | 990 |
| Factions | `/faction=` | Faction | 858 |
| Holidays | `/event=` | Holidays | 756 |
| Titles | `/title=` | CharTitles | 698 |
| Emotes | `/emote=` | Emotes | 494 |
| Professions | `/profession=` | SkillLine | 395 |
| Dungeons | `/dungeon=` | JournalInstance | 211 |
| Heirlooms | heirloom pages | Heirloom | 135 | *subset of Items* |
| Pet Families | `/petfamily=` | CreatureFamily | 85 |
| Races | `/race=` | ChrRaces | 58 |
| Classes | `/class=` | ChrClasses | 15 |
| **TOTAL (raw)** | | | **~725,685** |

**Deduplication note**: Toys (1,130) and Heirlooms (135) are subsets of Items — their `/item=` pages are already captured by the Items scrape. Battle Pets (2,936) use `/npc=` URLs already covered by the NPC scrape. These subsets still need their own parsers to extract pet/toy/heirloom-specific data from the cached HTML, but they don't generate additional HTTP requests.

**Deduplicated request count: ~721,484 unique URLs.**

### Cost Analysis

- **AWS Lambda free tier**: 1M requests/month + 400K GB-seconds
- **Full Wowhead vacuum**: ~721K requests = fits in free tier for invocations
- **Network egress**: Lambda charges $0.09/GB outbound. ~721K pages × ~200KB avg = ~144GB = **~$13**. This is the real cost, not the compute.
- **2M requests** (with retries + other sites): ~$1.87 compute + ~$36 egress = **~$38**
- **10M requests**: ~$20 compute + ~$180 egress = **~$200**
- **Residential proxies equivalent**: $100-150 per scrape (comparable at scale, but no IP reputation advantage of Lambda)

**Bottom line**: A full Wowhead vacuum costs ~$13 in egress. Not free, but 10x cheaper than residential proxies and infinitely more reliable than Tor.

### Concurrency Model

- Local orchestrator dispatches N concurrent Lambda invocations (target: 500-1000)
- Each Lambda invocation is stateless — one request, one response
- No circuit management needed (each invocation = fresh IP)
- Orchestrator handles retry queue, WAF detection, result collection
- Staggered dispatch to avoid Lambda cold-start thundering herd

### Data Flow

```
[DB2 Pre-Filter] → [ID Lists] → [Local Orchestrator]
                                       |
                              ┌────────┴────────┐
                              │                  │
                        [Lambda Fleet]     [Tor Fallback]
                        (primary, free)    (if Lambda blocked)
                              │                  │
                              └────────┬─────────┘
                                       │
                              [Local Parser Engine]
                                       │
                              [JSON + gzip HTML output]
                              wago/wowhead_data/{target}/
```

### Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `wago/scraper_v4.py` | CREATE | Local orchestrator with Lambda dispatch |
| `wago/lambda_scraper/handler.py` | CREATE | Lambda function handler |
| `wago/lambda_scraper/requirements.txt` | CREATE | curl_cffi dependency for Lambda layer |
| `wago/lambda_scraper/deploy.sh` | CREATE | Package + deploy Lambda function |
| `wago/generate_id_lists.py` | CREATE | DB2 pre-filter → ID list generator |
| `wago/scraper_v3.py` | PRESERVE | Keep as Tor-only fallback, no changes |

### Deployment Complexity — curl_cffi on Lambda

**This is the hardest part of the project.** `curl_cffi` is not a pure Python package — it wraps `libcurl-impersonate`, a C library that provides real browser TLS fingerprinting (JA3/JA4). It cannot be `pip install`'d into a Lambda zip on Windows and expected to work.

**Required approach:**
1. Build the Lambda Layer on Amazon Linux 2 (Lambda's runtime OS). Options:
   - Use an EC2 instance or Cloud9 to `pip install curl_cffi -t layer/python/` and zip it
   - Use a Docker container: `docker run -v ./layer:/out amazonlinux:2 bash -c "pip install curl_cffi -t /out/python/"`
   - Use a pre-built Lambda Layer from the curl_cffi community if one exists
2. Upload the layer to AWS Lambda (`aws lambda publish-layer-version`)
3. Attach the layer to the function

**Fallback if curl_cffi Layer proves too painful:** Use `httpx` with custom TLS settings instead. Lower fingerprint fidelity than curl_cffi, but still far better than raw `requests`. Since Lambda IPs already have decent trust scores, perfect fingerprinting may be less critical than it was for Tor.

### AWS Setup Requirements

- AWS account with Lambda access (free tier eligible)
- IAM role with `lambda:InvokeFunction` permission
- Optional: S3 bucket for oversized responses (only needed if any page exceeds 6MB compressed)
- boto3 installed locally (`pip install boto3`)
- AWS CLI configured (`aws configure`)
- Lambda function deployed with curl_cffi layer (see Deployment Complexity above)
- **Default concurrency limit**: 1,000 per region. If dispatching 500-1000 concurrent invocations, verify account limit (`aws lambda get-account-settings`) and request increase if needed

### Preserved from v3

- All 7 page parsers (quest, npc, item, spell, object, trainer, vendor)
- StatsTracker with live dashboard
- HTML caching (gzip level 1)
- Resumable scraping (skip existing output files)
- Reparse mode (offline re-extract from cached HTML)
- Work item priority queue with retry/drop logic
- Smoke test mode

### New Parsers Required

v3 has 7 parsers. The full 28-entity scrape needs **21 new parsers**. These can be implemented incrementally — the scraper fetches and caches HTML for all targets, and new parsers can be added later and run in `--reparse` mode against cached HTML without any additional network requests.

**Phase 1 — ship with v4 (high-value, unique URL patterns):**
- `parse_achievement_page` — criteria, rewards, points, category, faction
- `parse_mount_page` — source, spell, model, faction requirement
- `parse_currency_page` — cap, source, used-for
- `parse_transmog_set_page` — items, class restrictions, visual theme
- `parse_questline_page` — quest chain, order, zone
- `parse_event_page` — dates, quests, achievements, vendors

**Phase 2 — add via reparse (lower priority, share URL patterns with existing parsers):**
- `parse_pet_page` — abilities, breed, source (reparse from cached `/npc=` HTML)
- `parse_toy_page` — effect, source, cooldown (reparse from cached `/item=` HTML)
- `parse_heirloom_page` — upgrade tiers, stats (reparse from cached `/item=` HTML)
- `parse_garrison_mission_page`, `parse_follower_page`, `parse_itemset_page`, `parse_faction_page`, `parse_title_page`, `parse_dungeon_page`, `parse_flightpath_page`, `parse_profession_page`, `parse_emote_page`, `parse_petfamily_page`, `parse_race_page`, `parse_class_page`

### Success Criteria

- Full Wowhead scrape completes in < 2 hours
- WAF block rate < 5% (vs ~60-70% with Tor-only)
- Total cost per full scrape: ~$13 (network egress), compute free-tier
- Tor fallback activates automatically on Lambda rate-limiting
- DB2 pre-filtering eliminates 35-40% of wasted requests
- All 7 existing parsers produce identical output to v3 (regression test)
- Phase 1 parsers (6 new entity types) ship with v4 launch

---

**Implementation**: Claude Code
**QA**: Antigravity
**Approval**: User (Adam)
