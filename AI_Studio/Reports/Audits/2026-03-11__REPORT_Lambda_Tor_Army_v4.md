# Lambda Tor Army v4 — Implementation Report

**Session**: 140
**Date**: 2026-03-11
**Commit**: `f01054e84c`
**Status**: BUILT — awaiting AWS account setup + first deploy

---

## Executive Summary

Replaced the Tor-based Wowhead scraper (v3) with an AWS Lambda-based architecture (v4). Tor exit nodes have rock-bottom Cloudflare trust scores (~60-70% WAF block rate). Lambda datacenter IPs are significantly more trusted (<5% expected block rate). DB2 pre-filtering reduces the scrape universe from ~1.2M brute-force IDs to 721,514 validated IDs (40% savings). Cost per full Wowhead vacuum: ~$13 (network egress), compute free-tier.

## Architecture

### Three Components

```
[DB2 Pre-Filter] → [ID Lists] → [Local Orchestrator]
                                       |
                              [AWS Lambda Fleet]
                              (500 concurrent invocations)
                                       |
                              [Local Parser Engine]
                                       |
                              [JSON + gzip HTML output]
                              wago/wowhead_data/{target}/
```

1. **Local Orchestrator** (`wago/scraper_v4.py`, 380 lines)
   - Runs on local machine
   - Manages async work queue (PriorityQueue, same design as v3)
   - Fans out to Lambda via `aioboto3` async client
   - Collects zstd-compressed HTML responses
   - Parses locally using fast regex extractors
   - Writes parsed JSON + gzipped HTML cache
   - Live dashboard: rate/hr, WAF/min, per-target breakdown, ETA
   - Resumable: skips existing output files
   - Smoke test mode: `--smoke N` limits to first N items

2. **Lambda Worker** (`wago/lambda_scraper/handler.py`, 65 lines)
   - Docker container deployed to AWS Lambda (not Lambda Layers)
   - Base image: `public.ecr.aws/lambda/python:3.12`
   - Dependencies: `curl_cffi` (browser TLS fingerprinting), `zstandard`
   - Single responsibility: fetch one URL, return zstd-compressed HTML
   - 7 browser fingerprints (Chrome 120/124/131, Edge 101, Safari 17.0/17.2, Firefox 120)
   - WAF detection: HTTP 403 or `cf-challenge` in short responses
   - Memory: 256MB, Timeout: 30s
   - Payload safety: gzip under 6MB limit, oversized flag for outliers

3. **DB2 Pre-Filter** (`wago/generate_id_lists.py`, 115 lines)
   - Reads Wago DB2 CSVs via `wago_common.load_wago_csv()`
   - Outputs one ID list per entity type to `wago/id_lists/{target}.txt`
   - 25 targets mapped to their DB2 source tables
   - Tracks subset relationships (toys⊂items, pets⊂npcs, heirlooms⊂items)

### Parser Module (`wago/parsers.py`, 370 lines)

Plugin registry with fast regex/string extractors. No DOM parsing (BeautifulSoup rejected — 10-100x slower at scale).

**Shared extractors** (from v3):
- `_extract_listview_data()` — WH.Listview JavaScript arrays
- `_extract_g_data()` — $.extend(g_npcs[ID], {...}) globals
- `_extract_mapper_data()` — g_mapperData spawn coordinates
- `_extract_infobox()` — sidebar key-value pairs (new for v4)

**13 parsers registered:**

| Parser | Target(s) | Extracts |
|--------|-----------|----------|
| `parse_npc_page` | npc, trainer, vendor | g_npcs, coords, vendor items, teaches, drops, abilities, skinning, pickpocket, models, quests, sounds |
| `parse_quest_page` | quest | start/end NPCs+GOs, progress/reward text, g_quests (level, side, money, xp) |
| `parse_item_page` | item | sold-by, dropped-by, quest rewards, contained-in, g_items (class, quality, slot) |
| `parse_spell_page` | spell | taught-by-npc, used-by-npc |
| `parse_object_page` | object | g_objects, coords, quest starts/ends, contains items |
| `parse_achievement_page` | achievement | g_achievements, criteria, reward items/spells/titles, series chain |
| `parse_mount_page` | mount | infobox (source, speed, faction), spell ID, displayIds, drop/vendor/quest sources |
| `parse_currency_page` | currency | infobox (category, cap), purchases, quest rewards |
| `parse_transmog_set_page` | transmog_set | set items with slot info, infobox (class, type, source) |
| `parse_questline_page` | questline | ordered quest chain, infobox (zone, faction, level) |
| `parse_event_page` | event | infobox (dates, duration), quests, achievements, items, npcs |

**3 targets without parsers yet** (Phase 2 — add via `--reparse`): faction, item_set, title

## DB2 Pre-Filtered ID Counts (build 66337)

| Tier | Entity | DB2 Table | Valid IDs | Existing |
|------|--------|-----------|-----------|----------|
| 1 | Spells | SpellName | 400,101 | 0 |
| 1 | Items | ItemSparse | 170,130 | 0 |
| 1 | Quests | QuestV2 | 65,187 | 19,614 |
| 1 | GameObjects | GameObjects | 29,025 | 555 |
| 1 | NPCs | Creature | 22,747 | 309,996* |
| 1 | Achievements | Achievement | 13,622 | 0 |
| 2 | Transmog Sets | TransmogSet | 4,883 | 0 |
| 2 | Garrison Missions | GarrMission | 1,757 | 0 |
| 2 | Quest Lines | QuestLine | 1,640 | 0 |
| 2 | Mounts | Mount | 1,598 | 0 |
| 2 | Currencies | CurrencyTypes | 1,449 | 0 |
| 2 | Flight Paths | TaxiNodes | 1,449 | 0 |
| 2 | Maps/Zones | Map | 1,166 | 0 |
| 2 | Journal Encounters | JournalEncounter | 1,147 | 0 |
| 2 | Garrison Followers | GarrFollower | 1,053 | 0 |
| 2 | Trainers | (legacy file) | 1,022 | 1,022 |
| 2 | Item Sets | ItemSet | 990 | 0 |
| 2 | Factions | Faction | 858 | 0 |
| 2 | Holidays/Events | Holidays | 756 | 0 |
| 2 | Titles | CharTitles | 698 | 0 |
| 2 | Emotes | Emotes | 494 | 0 |
| 2 | Professions | SkillLine | 395 | 0 |
| 2 | Dungeons | JournalInstance | 211 | 0 |
| 2 | Pet Families | CreatureFamily | 85 | 0 |
| 2 | Races | ChrRaces | 58 | 0 |
| 2 | Classes | ChrClasses | 15 | 0 |
| | **TOTAL** | | **721,514** | |

*NPC "existing" count of 309,996 is from v3 brute-force scraping the full 0-240K ID range. Only 22,747 of those IDs actually exist in DB2.

**Subset targets** (no extra HTTP requests — parsed from parent target's cached HTML):
- Toys (1,130) — subset of Items
- Heirlooms (135) — subset of Items
- Battle Pets (2,936) — subset of NPCs

## Cost Analysis

| Scenario | Compute | Egress (144GB @ $0.09/GB) | Total |
|----------|---------|---------------------------|-------|
| Full Wowhead vacuum (721K) | $0 (free tier) | ~$13 | ~$13 |
| With retries (1M) | $0 (free tier) | ~$18 | ~$18 |
| 2M requests (other sites) | ~$1.87 | ~$36 | ~$38 |
| Residential proxies (comparison) | — | — | $100-150 |

## Files Created

All files live in `wago/` which is gitignored. The spec and review are tracked in git.

### Implementation (gitignored — in `wago/`)

| File | Lines | Purpose |
|------|-------|---------|
| `wago/scraper_v4.py` | 380 | Local orchestrator — work queue, Lambda dispatch, parsing, dashboard |
| `wago/parsers.py` | 370 | 13 page parsers + 4 shared extractors |
| `wago/generate_id_lists.py` | 115 | DB2 CSV → pre-filtered ID list files |
| `wago/lambda_scraper/handler.py` | 65 | Lambda function — fetch + zstd compress |
| `wago/lambda_scraper/Dockerfile` | 7 | Container image (python:3.12 + curl_cffi + zstd) |
| `wago/lambda_scraper/requirements.txt` | 2 | curl_cffi, zstandard |
| `wago/lambda_scraper/deploy.sh` | 60 | Build, push to ECR, create/update Lambda |
| `wago/id_lists/*.txt` | 25 files | 721,514 validated entity IDs |

### Tracked in git

| File | Purpose |
|------|---------|
| `AI_Studio/2_Active_Specs/2026-03-11__TRIAD-SCRAPER-V4__lambda_tor_army_architecture.md` | Approved spec |
| `AI_Studio/Reports/Audits/2026-03-11__REVIEW_lambda_tor_army.md` | Antigravity review |

## Dependencies Installed

```
pip install aioboto3 zstandard
```

These were installed to the system Python (`C:\Python314`). `curl_cffi` is only needed inside the Lambda container (not locally).

Installed packages: `aioboto3`, `aiobotocore`, `aiofiles`, `aioitertools`, `boto3`, `botocore`, `jmespath`, `s3transfer`, `wrapt`, `zstandard`

## Antigravity Review — Enhancements Applied

| # | Enhancement | Antigravity's Suggestion | Our Decision | Rationale |
|---|-------------|--------------------------|--------------|-----------|
| 1 | Deployment | Docker container, not Lambda Layer | **ADOPTED** | Eliminates curl_cffi C-library compilation headaches entirely |
| 2 | Parser generation | AI parser forge + BeautifulSoup | **REJECTED** | Regex is 10-100x faster than DOM at scale. Existing `_extract_listview_data` patterns cover all Wowhead page structures. Not over-engineering a solved problem |
| 3 | Compression | Zstandard instead of gzip | **ADOPTED** | Better compression ratio for HTML, saves ~$3-4 on egress. One-line change |
| 4 | Fallback | Remove Tor, add Google Cloud Run | **PARTIALLY ADOPTED** | Tor removed from v4 dependency chain. GCR fallback rejected (YAGNI — AWS has hundreds of thousands of IPs). v3 preserved untouched as standalone fallback if ever needed |

## Deployment Procedure (for next session)

### Prerequisites
1. AWS account (free tier eligible)
2. Docker Desktop installed and running
3. AWS CLI installed (`winget install Amazon.AWSCLI`)

### Step-by-step

```bash
# 1. Configure AWS credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output (json)

# 2. Create ECR repository (one-time)
aws ecr create-repository --repository-name lambda-tor-army --region us-east-1

# 3. Create IAM role for Lambda (one-time)
aws iam create-role --role-name lambda-tor-army-role \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name lambda-tor-army-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# 4. Build and deploy container
cd ~/VoxCore/wago/lambda_scraper
chmod +x deploy.sh
./deploy.sh --create

# 5. Verify Lambda function exists
aws lambda get-function --function-name lambda-tor-army

# 6. Smoke test (single invocation)
aws lambda invoke --function-name lambda-tor-army \
  --payload '{"url":"https://www.wowhead.com/npc=1"}' /dev/stdout

# 7. Smoke test (50 pages via orchestrator)
cd ~/VoxCore/wago
python scraper_v4.py --targets npc --smoke 50

# 8. Check Lambda concurrency limit
aws lambda get-account-settings
# If "ConcurrentExecutions" < 500, request increase via AWS console

# 9. Full scrape (start small, scale up)
python scraper_v4.py --targets npc --concurrency 100
python scraper_v4.py --targets npc,quest,item --concurrency 500
python scraper_v4.py --targets npc,quest,item,spell,object,achievement --concurrency 500
```

### Verification after first scrape
```bash
# Check output
python scraper_v4.py --list-targets

# Spot-check a few parsed files
cat wago/wowhead_data/npc/pages/npc_1.json | python -m json.tool
cat wago/wowhead_data/quest/raw/1_questgivers.json | python -m json.tool
```

## v3 Preserved

`wago/scraper_v3.py` is untouched. It remains a fully functional standalone Tor-based scraper. If Lambda is ever unavailable, v3 can run independently with no code changes. The two systems share no runtime dependencies.

## What Was NOT Done (Anti-Theater Compliance)

1. **AWS account not configured** — no credentials exist yet. Lambda function has never been deployed or invoked
2. **End-to-end test not run** — the orchestrator loads IDs and builds the work queue correctly (verified via `--list-targets`), but no actual Lambda invocations have occurred
3. **3 Phase 2 parsers not written** — faction, item_set, title. These are low-priority targets (<2,600 IDs combined). Can be added anytime and run via `--reparse` on cached HTML
4. **Lambda concurrency limit not verified** — default is 1,000, we target 500. May need increase request for full-speed scraping
5. **Egress cost estimate is theoretical** — based on 200KB average page size × 721K pages. Actual may vary

## CLI Reference

```bash
# Generate pre-filtered ID lists from DB2
python generate_id_lists.py                     # All 25 targets
python generate_id_lists.py --stats             # Counts only
python generate_id_lists.py --targets npc,quest # Specific targets
python generate_id_lists.py --include-subsets   # Also generate toy/pet/heirloom

# Scrape via Lambda
python scraper_v4.py --targets npc --concurrency 500
python scraper_v4.py --targets npc,quest,item,spell,object,achievement
python scraper_v4.py --targets npc --smoke 50   # Test with 50 pages
python scraper_v4.py --list-targets             # Show status
python scraper_v4.py --targets npc --reparse    # Re-extract from cached HTML
python scraper_v4.py --no-cache-html            # Skip HTML caching
python scraper_v4.py --function-name my-func    # Custom Lambda name
python scraper_v4.py --region eu-west-1         # Custom AWS region
```
