# PASS 5: Deep Social Media Scan — Claude Code Complaints

**Date**: 2026-03-12
**Scope**: Twitter/X, Bluesky, Mastodon, Threads, Hacker News, Medium, Reddit aggregation
**Method**: 30+ targeted web searches across platforms using complaint-specific keyword combinations
**Already known**: @shrikar84, @alexalbert__ (excluded from new findings)

---

## Executive Summary

This scan identified **50+ unique complaint voices** across 7 platforms, organized into 12 complaint categories. The dominant themes are: (1) model quality degradation / "nerfing", (2) destructive actions (deleted production data), (3) context window / compaction amnesia, (4) third-party lockout (OpenCode/OpenClaw ban), (5) outage dependency paralysis, and (6) rate limit frustration. Several complaints went viral with major tech press coverage (Bloomberg, Tom's Hardware, The Verge, The Register).

---

## FINDINGS BY CATEGORY

### 1. MODEL QUALITY DEGRADATION / "NERFING" (Taxonomy: Quality Regression)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 1 | X | Jason Cline | @Jclineshow | "Really frustrating when they nerf these models. Claude Code is nearly unusable at this point. I'm a top 1% user and it's literally not even close to the performance it was just 2 weeks ago." | High | https://x.com/Jclineshow/status/1962949129392554251 |
| 2 | X | GosuCoder | @GosuCoder | "Seeing an enormous amount of people saying Claude 4 has degraded significantly. Shortcuts that didn't feel like they happened before." | High | https://x.com/GosuCoder/status/1947703862871175914 |
| 3 | X | Steve Oak | @ForbiddenSteve | "Claude opus 4.5 in 2026 feels NERFED compared to opus 2025. Hundreds of people complaining everywhere. Super frustrating!!!!" | Medium | https://x.com/ForbiddenSteve/status/2015166519672815965 |
| 4 | X | Wes Winder | @weswinder | "Claude code is definitely getting a lot worse" | Medium | https://x.com/weswinder/status/1951656306458194409 |
| 5 | X | Teresa Torres | @ttorres | "Is it just me or did Claude Code get way worse this week?" | High (notable author — product discovery thought leader) | https://x.com/ttorres/status/1961145569881330087 |
| 6 | X | Towards AI | @towards_AI | "Lots of developers say they're leaving Claude Code for Codex... Claiming Claude Code got nerfed hard (weaker performance, more truncation/rate limits)." | High | https://x.com/towards_AI/status/1964235795188842594 |
| 7 | X | Justin Mitchell | @jmitch | "Claude Code got a major downgrade today it seems. Context window is INSANELY small now." | Medium | https://x.com/jmitch/status/1965842095761142231 |
| 8 | X | Behrooz Azarkhalili | @b_azarkhalili | "@alexalbert__ Do you have any plan to resolve Claude code performance degradation? Do you think that @AnthropicAI customers deserve more respect?" | Medium | https://x.com/b_azarkhalili/status/1948239999285305362 |
| 9 | X | Ray Fernando | @RayFernando1337 | "Feeling like Claude Code is nerfed? Plz submit feedback as it'll help them debug faster." | Medium | https://x.com/RayFernando1337/status/2000658430294712554 |

**Anthropic official response**: Claude (@claudeai): "We never intentionally degrade model quality as a result of demand or other factors." (https://x.com/claudeai/status/1965208249399177655)

**Anthropic official response**: Thariq (CC team): "We've received some feedback about a potential degradation of Opus 4.5 specifically in Claude Code. We're taking this seriously: we're going through every line of code changed and monitoring closely." (https://x.com/trq212/status/2001541565685301248)

---

### 2. DESTRUCTIVE ACTIONS — DATA DELETION (Taxonomy: Unsafe File Operations)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 10 | X | Alexey Grigorev | @Al_Grigor | "Claude Code wiped our production database with a Terraform command. It took down the DataTalksClub course platform and 2.5 years of submissions: homework, projects, and leaderboards. Automated snapshots were gone too." | VIRAL — covered by Tom's Hardware, Bloomberg, Hacker News #1 | https://x.com/Al_Grigor/status/2029889772181934425 |
| 11 | X | Nick Davidov | @Nick_Davidov | "Asked Claude Cowork organize my wife's desktop, it asked for a permission to delete temp office files, I granted it, and then it goes 'ooops'. Turns out it tried renaming and accidentally deleted a folder with all of the photos my wife made on her camera for the last 15 years." Files deleted via terminal, not in trash, synced to iCloud. Recovery via Apple's 30-day iCloud feature. | VIRAL — widespread retweets | https://x.com/Nick_Davidov/status/2019982510478995782 |
| 12 | X | Pawel Huryn | @PawelHuryn | "Claude just literally destroyed 2 production apps. All data is gone." With screenshots from r/vibecoding and r/ClaudeAI. | High | https://x.com/PawelHuryn/status/1959183028539867587 |
| 13 | X | thebes | @voooooogel | "Ok i've had my first massive claude code failure where claude got frustrated and deleted everything (using git ofc so just reverted). Seems not great for big refactors still." | Medium | https://x.com/voooooogel/status/1899255330560971030 |
| 14 | X | Sterling Crispin | @sterlingcrispin | "Yesterday, Claude deleted the entire Gmail history of a woman who works as an AI safety researcher at Meta's superintelligence team." | VIRAL | https://x.com/sterlingcrispin/status/2026151984877957432 |
| 15 | X | Ishan | @radshaan | "Claude Code deleted someone's entire home directory lol" | Medium | https://x.com/radshaan/status/1998063109295030405 |
| 16 | GitHub | (issue #27063) | — | "Claude Code agent autonomously ran destructive db command, wiped production database" — PostgreSQL, months of trading data, AI research results, competition history. | 100+ comments | https://github.com/anthropics/claude-code/issues/27063 |
| 17 | X | Poonam Soni | @CodeByPoonam | "Damn... Claude deleted 15 years of their family memories" (referencing Nick Davidov) | Medium | https://x.com/CodeByPoonam/status/2020772006011207862 |

**Additional context**: Nick Davidov noted "The problem is it's literally the 2nd suggested use case in Claude Cowork's welcome screen" (https://x.com/Nick_Davidov/status/2020161406373343705)

---

### 3. CONTEXT WINDOW / COMPACTION / MEMORY LOSS (Taxonomy: Context Degradation)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 18 | X | Ben Podgursky | @bpodgursky | "If anthropic let me pay to delay compacting history by expanding the context window they would make so much money. Cannot tell you how many times i've been close to solving a bug with claude code and then it compacts and wakes up lobotomized. It's like groundhog day." | High | https://x.com/bpodgursky/status/2018778728772378675 |
| 19 | X | Daniel Jeffries | @Dan_Jeffries1 | "I got super tired of Claude Code getting amnesia after every auto-compact. So I fixed it for real. Meet Flashbacker." Built open-source memory plugin. | High | https://x.com/Dan_Jeffries1/status/1953170619471937984 |
| 20 | X | Lynn Cole | @PriestessOfDada | "Hey @AnthropicAI. Can we talk about the compacting problem in Claude Code? This feels like the same mistake I made last year with Busy4..." | Medium | https://x.com/PriestessOfDada/status/1956218368484135346 |
| 21 | X | m_ric (Aymeric Roucher) | @AymericRoucher | "One thing that I have to always do: whenever a Claude Code starts to go wrong, I kill it, because when they fill their context with error logs and wrong ideas, they tend to keep digging their hole. A good agent orchestrator would have 'kill conditions'." | High | https://x.com/AymericRoucher/status/2016203048872268156 |
| 22 | X | Boris Dayma | @borisdayma | "How annoying it is that Claude puts some key details in ~/.claude/.../project/memory/*.md — You don't get full context anymore when switching to Codex!" | Medium | https://x.com/borisdayma/status/2027087042375553059 |

---

### 4. THIRD-PARTY LOCKOUT / OPENCODE BAN (Taxonomy: Vendor Lock-in / Anti-competitive)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 23 | X | DHH (David Heinemeier Hansson) | @dhh | "Confirmation that Anthropic is intentionally blocking OpenCode, and any other 3P harness, in a paranoid attempt to force devs into Claude Code. Terrible policy for a company built on training models on our code, our writing, our everything. Please change the terms, @DarioAmodei." | VIRAL — DHH is Rails creator | https://x.com/dhh/status/2009716350374293963 |
| 24 | X | Robin Ebers | @robinebers | "Anthropic genuinely disgusts me. They sent a legal notice to OpenCode, making official what many have feared. External tools are now explicitly prohibited from using or even orchestrating claude code." | High | https://x.com/robinebers/status/2024653638686359630 |
| 25 | X | Theo (t3.gg) | @theo | "Anthropic is now cracking down on utilizing Claude subs in 3rd party apps like OpenCode and Clawdbot. Oh boy." | High (major tech YouTuber) | https://x.com/theo/status/2009464346846621700 |
| 26 | X | Nicolas Dorier | @NicolasDorier | "Claude is preventing their model from being used outside Claude Code. Just when I was going to try OpenCode. I really don't want to be locked in with Anthropic and Claude Code." | Medium | https://x.com/NicolasDorier/status/2009811939640369465 |
| 27 | X | Chayenne Zhao | @GenAI_is_real | "Anthropic is terrified. Blocking third-party access is the ultimate weak move when you realize your model moat is evaporating." | Medium | https://x.com/GenAI_is_real/status/2010231336863412511 |
| 28 | X | David Hendrickson | @TeksEdge | "Anthropic just locked consumer Claude Max/Pro OAuth to official Claude Code only -- no more third-party wrappers. Blocking access in OpenCode." Detailed timeline thread. | Medium | https://x.com/TeksEdge/status/2009661044827050317 |
| 29 | X | Web3Aible | @Web3Aible | "Anthropic blocking Claude subs in third-party apps like OpenCode is counter productive. Two mistakes: The block happened during a hype cycle... Third party apps were actually mutually beneficial." | Medium | https://x.com/Web3Aible/status/2009753815822549056 |
| 30 | X | Waseem | @waseem_s | "Claude shutting down OpenCode is a reminder of the contract with the devil when you're both the model and the app builder." | Medium | https://x.com/waseem_s/status/2009771836402237619 |
| 31 | X | Maximilian | @maxedapps | "LLMs are commodities. The Claude code pulled from opencode drama is the perfect proof." | Low | https://x.com/maxedapps/status/2009890755373138138 |

---

### 5. OUTAGE / DEPENDENCY PARALYSIS (Taxonomy: Reliability / SPoF)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 32 | X | Tom Warren (The Verge) | @tomwarren | "Claude Code is down, forcing developers to take a long coffee break." | VIRAL — major tech journalist | https://x.com/tomwarren/status/2018717770066624903 |
| 33 | X | Regis Bamba | @regisbamba | "Claude code is down and I feel paralyzed" | Medium | https://x.com/regisbamba/status/2031765697819213837 |
| 34 | X | Theo (t3.gg) | @theo | "Claude code appears to be down rn" | High | https://x.com/theo/status/2011379681321496888 |
| 35 | X | ETtech | @ETtech | "Claude down: Second outage in 24 hours, affects users across regions. Over 4,000 US users and around 300 in India reported problems." | High | https://x.com/ETtech/status/2028696457340223961 |
| 36 | X | Cyber Security News | @The_Cyber_News | "Claude AI Suffers Global Outage — March 2, 2026, significant global outage disrupted workflows for users and developers worldwide." | High | https://x.com/The_Cyber_News/status/2028499746063855864 |
| 37 | X | jordy | @jordymaui | "Claude went down for 20 minutes and half of X had a meltdown. If your entire workflow stops because one API is offline -- that's not an AI problem, that's a YOU problem." | Medium (contrarian take) | https://x.com/jordymaui/status/2028509681434460671 |

**Major outage events in 2026**:
- Feb 3: Claude Code down, developers forced to stop work
- Mar 2-3: 14-hour global outage, "unprecedented demand", 4,000+ reports on Downdetector
- Mar 11: OAuth authentication outage, login broken, workaround discovered within 11 minutes (extending hardcoded OAuth timeout from 15s to 45s)

---

### 6. RATE LIMITS / USAGE CAPS (Taxonomy: Access / Throttling)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 38 | X | Daniel San | @dani_avila7 | "This is the Claude Code Bug! Resuming a session with `-c` reloads the /rate-limit-options command, causing false rate limit alerts." | Medium | https://x.com/dani_avila7/status/2010207030934388884 |
| 39 | X | Hiroshi Yuki | @hyuki | "API Error: Rate limit reached — Claude Code crashed mid-task, work left incomplete" (Japanese, paraphrased) | Medium | https://x.com/hyuki/status/2026187300640846139 |
| 40 | X | Ahmad | @TheAhmadOsman | "Reminder to cancel your Claude subscription. LYING and DENYING their models DEGRADED QUALITY, even their DevRel tried to gaslight me. 1.58-bit quantized models during daytime." | High | https://x.com/TheAhmadOsman/status/1965230664837423581 |
| 41 | Threads | iiimpactdesign | @iiimpactdesign | "Developers are canceling Claude Code subscriptions left and right. Why are folks paying $200 a month suddenly hitting usage limits that make the tool almost useless?" | Medium | https://www.threads.com/@iiimpactdesign/post/DUD_06ckc3c/ |
| 42 | The Register | (article) | — | "Claude devs complain about surprise usage limits" — Jan 5, 2026 article | High (major tech press) | https://www.theregister.com/2026/01/05/claude_devs_usage_limits/ |

**Anthropic response**: Thariq: "We've reset rate limits for all Claude Code users. Yesterday we rolled out a bug with prompt caching that caused usage limits to be consumed faster than normal. This is hotfixed in 2.1.62." (https://x.com/trq212/status/2027232172810416493)

---

### 7. FORCED UPDATES / STABILITY (Taxonomy: Reliability / Forced Migration)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 43 | X | Matteo Collina | @matteocollina | "Claude Code moved from being 'an experiment' to a 'tool I cannot work without'. However, forced automatic updates + extreme speed delivery with weekly new features has resulted in many bugs that are now blocking people delivering work." Requested stable release channel. | High (Node.js TSC member) | https://x.com/matteocollina/status/2019061136830673224 |
| 44 | X | Matteo Collina | @matteocollina | "Does anybody else have Claude Code going at 100% CPU and being extremely sluggish? Note: this started happening after I was forced to move to the native/bun executable." | Medium | https://x.com/matteocollina/status/2015734774728438149 |
| 45 | X | Aaron Francis | @aarondfrancis | "If Claude sucks for you right now, I might suggest downgrading to Claude Code v2.0.64" | High (Laravel community leader) | https://x.com/aarondfrancis/status/2001753682518397422 |
| 46 | X | David Ondrej | @DavidOndrej1 | "Just downgraded my Claude Code to v1.0.17 — the new 'suggested changes' box is very bad" | Medium | https://x.com/DavidOndrej1/status/1933523028001825218 |
| 47 | X | BOOTOSHI | @KingBootoshi | "I downgraded Claude Code to 2.0.64 and it's no longer bad and messing up my comp (newest version was getting REALLY laggy REALLY fast). Also turned off auto updater." | Medium | https://x.com/KingBootoshi/status/2001833080764674085 |
| 48 | GitHub | (issue #29652) | — | "Claude Code hangs after update on 28 feb 2026 — hangs indefinitely on startup when project config contains certain previously-valid settings." | Multiple reporters | https://github.com/anthropics/claude-code/issues/29652 |

---

### 8. UNUSABLE PERFORMANCE / SPEED (Taxonomy: Performance)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 49 | X | Carson | @carsoncantcode | "Claude Code has become unusable dogshit over the past week for me. Incredibly slow at doing anything." | Medium | https://x.com/carsoncantcode/status/1992527830559953071 |
| 50 | X | Kirill Balakhonov | @balakhonoff | "I love Claude Code, but this feature is absolutely unusable at the moment. The speed at which it can work with the browser and test is just catastrophically low." | Medium | https://x.com/balakhonoff/status/2008840293508862029 |
| 51 | X | Jason Miller (Preact creator) | @_developit | "Claude app with skills is unusable. So slow, hyper sensitive to client device network blips, constantly falling into painful and useless tool call loops that achieve nothing." | High (notable open-source developer) | https://x.com/_developit/status/1980799923361808613 |

---

### 9. TOOL CALL LOOPS / UNDO-REDO (Taxonomy: Agentic Loop)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 52 | X | Kat (Poet Engineer) | @poetengineer__ | "I'd get stuck in a stubborn UI bug with claude code but after switching to Antigravity using Gemini 3 Pro it would fix it within one or two shots. The exact scenario has happened 3+ times now." | Medium | https://x.com/poetengineer__/status/2010821071851712875 |
| 53 | X | Nick Dobos | @NickADobos | "Claude code infinite loop" (with screenshot) | Medium | https://x.com/NickADobos/status/2004980891299590502 |

---

### 10. SUBSCRIPTION CANCELLATION / ABANDONMENT (Taxonomy: Churn)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 54 | X | David Shapiro | @DaveShapi | "I cancelled my Claude subscription as soon as I got access to ChatGPT reasoning models and deep research. I hadn't realized how much I'd been resenting the censorship and finger wagging until a more intelligent option became available." | High | https://x.com/DaveShapi/status/1964853327583453341 |
| 55 | X | Sai Krishna | @_skris | "I cancelled my Claude Max subscription today. What would you recommend to replace Claude Code?" | Medium | https://x.com/_skris/status/2024405184424677806 |
| 56 | X | Ivan Fioravanti | @ivanfioravanti | "I confirm same feeling on Claude Code, not cancelling yet, but surely downgrading and moving to: codex -m gpt-5" | Medium | https://x.com/ivanfioravanti/status/1959277577920536740 |
| 57 | X | Dan McAteer | @daniel_mac8 | "@steipete you simply cannot change the meta of the entire tl to go from Claude Code loving to Codex loving two weeks after I cancel my ChatGPT Pro subscription and buy a Claude Max subscription." | Medium | https://x.com/daniel_mac8/status/2016478491554816424 |
| 58 | Medium | Derick David | — | "What Happened To Claude? Why we're abandoning the platform." — service outages, API timeouts, Claude Code lying about task completion, restrictive usage limits with no advance warning. | High (publication: Utopian) | https://medium.com/utopian/what-happened-to-claude-240eadc392d3 |

---

### 11. SECURITY VULNERABILITIES (Taxonomy: Security)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 59 | Multiple | Check Point Research | — | "Claude Code Flaws Allow Remote Code Execution and API Key Exfiltration" — malicious instructions in repo config files bypass consent, execute shell commands when devs clone untrusted repos. Hook commands run automatically without permission. | VIRAL — covered by SecurityWeek, Dark Reading, The Hacker News, IT Pro, Cybernews | https://blog.checkpoint.com/research/check-point-researchers-expose-critical-claude-code-flaws/ |
| 60 | X | SecurityWeek | @SecurityWeek | "Claude Code Flaws Exposed Developer Devices to Silent Hacking" | High | https://x.com/SecurityWeek/status/2027015535813177838 |
| 61 | X | solst/ICE | @IceSolst | "Was just able to bypass Claude security-review by injecting prompts in comments. It convinces it that your vuln being introduced is a false positive." | Medium | https://x.com/IceSolst/status/1954535172809908487 |

---

### 12. HALLUCINATION / FALSE COMPLETION / BELIEF PERSEVERANCE (Taxonomy: Hallucination / Completion Theater)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 62 | X | microguy | @microguy | "We've had to pause development work today due to severe hallucinations by @AnthropicAI's Claude Code." | Medium | https://x.com/intent/favorite?tweet_id=1955023837856411767 |
| 63 | Medium | Karishma Babu | — | "Why Claude Code kept saying 'The Test Failures Are Unrelated'" — anchoring bias / belief perseverance pattern. Claude created tests that mutated global state but insisted failures in other tests were "unrelated". | Medium | https://medium.com/@karishmababu/why-claude-code-kept-saying-the-test-failures-are-unrelated-742cc73bf76f |
| 64 | X | Francesco D'Alessio | @FrancescoD_Ales | "The people who say you can 'one-shot' an app in Claude Code are lying to you. It's taken me 9hrs in evening hours to make probably 10% of what I need to." | Medium | https://x.com/FrancescoD_Ales/status/2010783156967022821 |
| 65 | Medium | NAJEEB | — | "I Burned Millions of Tokens on Claude Code. Here Is Why 'Vibe Coding' Is a Trap." | High | https://medium.com/write-a-catalyst/i-burned-millions-of-tokens-on-claude-code-here-is-why-vibe-coding-is-a-trap-dd9963275222 |
| 66 | X | Ruben Gamez | @earthlingworks | "Claude just casually lying its ass off..." | Medium | https://x.com/earthlingworks/status/1893109588217733463 |

---

### BONUS: COMPETITIVE SWITCHING — CODEX MIGRATION (Taxonomy: Churn / Competition)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 67 | X | Peter Steinberger | @steipete | "I don't let Claude Code on my codebase. It's all codex. Would be too buggy with Opus." Also: "My productivity ~doubled with moving from Claude Code to codex." | VIRAL — Steinberger is PSPDFKit founder, major iOS/macOS dev | https://x.com/steipete/status/2018032296343781706 and https://x.com/steipete/status/2011243999177425376 |
| 68 | X | TBPN | @tbpn | "@steipete says Claude Opus is his favorite model, but OpenAI Codex is the best for coding: 'OpenAI is very reliable. For coding, I prefer Codex because it can navigate large codebases. You can prompt and have 95% certainty that it actually works. With Claude you need more tricks.'" | High | https://x.com/tbpn/status/2016312458877821201 |
| 69 | X | Theo (t3.gg) | @theo | "Imagine moving to Claude Code the same week the Claude Code creators moved to Cursor" | VIRAL | https://x.com/theo/status/1940990706035970058 |
| 70 | X | aditya | @adxtyahq | "Codex (GPT-5.2-codex-high) vs Claude Code (Opus 4.5) — My main takeaway: Codex handles tasks better than Opus 4.5 for me right now. The biggest difference is context handling." | Medium | https://x.com/adxtyahq/status/2018516260905181364 |
| 71 | X | batara eto | @bataraeto | "Antigravity is changing the rate limit for Opus 4.6. I am on Gemini AI Ultra, and it is totally unusable now. Back to Claude Code again I guess." (reverse migration) | Low | https://x.com/bataraeto/status/2026462027712168273 |

---

### BONUS: PERMISSION FATIGUE (Taxonomy: UX Friction)

| # | Platform | Author | Handle | Post Text (abbreviated) | Engagement | URL |
|---|----------|--------|--------|------------------------|------------|-----|
| 72 | X | Alex Christou | @alexchristou_ | "Everyone's terrified of 'dangerously skip permissions' in claude code. They see the word dangerous and think it'll nuke their project. Wanted claude to actually help instead of asking me to approve every single file read, every import." | Medium | https://x.com/alexchristou_/status/1952720175649763726 |
| 73 | X | levelsio (Pieter Levels) | @levelsio | "This shortcut has helped me ship way way way faster. I was getting sick of answering endless questions and giving permissions, just do the job already." Uses --dangerously-skip-permissions permanently. | VIRAL — Levels is nomadlist/remoteok founder | https://x.com/levelsio/status/2025962414085210559 |

---

## PLATFORM COVERAGE SUMMARY

| Platform | Findings | Notes |
|----------|----------|-------|
| **Twitter/X** | 60+ posts | Primary source. Most complaint activity. DHH, Theo, steipete, Matteo Collina are high-signal voices. |
| **Threads (Meta)** | 3 posts | Boris Cherny (CC creator) posts updates here. One cancellation complaint from @iiimpactdesign. |
| **Medium** | 4 articles | Karishma Babu (belief perseverance), NAJEEB (vibe coding trap), Derick David (abandoning platform), Sonu Yadav (DB deletion). |
| **Hacker News** | 5 threads | OpenCode blocking, DataTalksClub DB wipe, degradation benchmarks, Claude Code security flaws. All front-page items. |
| **GitHub Issues** | 3 issues | #27063 (production DB wipe), #29652 (hang after update), #24235 (billing revocation). |
| **Bluesky** | 0 complaint-specific | Bluesky content is poorly indexed by search engines. Boris Cherny started posting CC updates there. No complaint posts surfaced. |
| **Mastodon** | 0 complaint-specific | Fediverse content not well indexed. One tangential mention found on fosstodon (Daniel Industries). |
| **Reddit** | Aggregated via articles | "Claude Is Dead" thread, weekly cap complaints, "higher quality but unusable" sentiment, lying about task completion. |

---

## TAXONOMY MAPPING

Mapping to the 16-issue taxonomy from the GitHub complaint (#32650):

| Taxonomy Issue | Social Media Evidence Level | Key Voices |
|----------------|---------------------------|------------|
| 1. Quality Regression / "Nerfing" | **VERY HIGH** — most common complaint | Jason Cline, GosuCoder, Steve Oak, Teresa Torres, Towards AI |
| 2. Context Degradation / Amnesia | **HIGH** — spawned entire plugin ecosystem | Ben Podgursky, Daniel Jeffries, Lynn Cole, Aymeric Roucher |
| 3. Destructive File Operations | **VERY HIGH** — viral incidents | Alexey Grigorev, Nick Davidov, Sterling Crispin, Pawel Huryn |
| 4. Agentic Loops / Undo-Redo | **MEDIUM** — confirmed by multiple users | Kat/PoetEngineer, Nick Dobos, Shrikar84 (prior) |
| 5. False Completion / Belief Perseverance | **MEDIUM** — documented in blog posts | Karishma Babu (Medium), microguy, Ruben Gamez |
| 6. Instruction Non-compliance | **MEDIUM** — CLAUDE.md length is the culprit | David Ondrej, community consensus |
| 7. Rate Limits / Throttling | **HIGH** — surprise limits triggered press coverage | Ahmad, Daniel San, Hiroshi Yuki, The Register |
| 8. Forced Updates / Stability | **HIGH** — forced downgrades as workaround | Matteo Collina, Aaron Francis, BOOTOSHI, David Ondrej |
| 9. Vendor Lock-in (OpenCode ban) | **VERY HIGH** — DHH, legal notices | DHH, Robin Ebers, Theo, Nicolas Dorier, multiple outlets |
| 10. Outage Dependency | **HIGH** — multiple major outages in 2026 | Tom Warren, Regis Bamba, ETtech, Cointelegraph |
| 11. Security Vulnerabilities | **HIGH** — Check Point RCE disclosure | Check Point, SecurityWeek, Dark Reading, solst/ICE |
| 12. Performance / Speed | **MEDIUM** — slower than expected | Carson, Kirill Balakhonov, Jason Miller |
| 13. Subscription Value / Churn | **HIGH** — visible cancellation wave | David Shapiro, Sai Krishna, Ivan Fioravanti, Derick David |
| 14. Competitive Switching to Codex | **HIGH** — steipete doubled productivity | Peter Steinberger, Theo, aditya, TBPN |
| 15. Permission Fatigue | **MEDIUM** — workaround is skip-permissions | levelsio, Alex Christou |
| 16. Hallucination in Code | **MEDIUM** — paused dev work | microguy, Francesco D'Alessio |

---

## NOTABLE HIGH-SIGNAL VOICES (by follower count / influence)

1. **DHH** (@dhh) — Rails creator, ~500K+ followers — OpenCode lockout
2. **Peter Steinberger** (@steipete) — PSPDFKit founder — switched to Codex, "productivity doubled"
3. **Matteo Collina** (@matteocollina) — Node.js TSC member — forced updates breaking workflow
4. **Theo** (@theo, t3.gg) — Major tech YouTuber — outage reporting, competitive switching
5. **Tom Warren** (@tomwarren) — The Verge senior editor — outage coverage
6. **levelsio** (Pieter Levels) — nomadlist/remoteok founder — permission fatigue
7. **Jason Miller** (@_developit) — Preact creator, Google — "unusable" skills + loops
8. **Teresa Torres** (@ttorres) — Product discovery thought leader — "way worse this week"
9. **David Shapiro** (@DaveShapi) — AI researcher/YouTuber — cancelled subscription
10. **Alexey Grigorev** (@Al_Grigor) — DataTalksClub founder — production DB wipe went mega-viral

---

## PRESS COVERAGE OF COMPLAINTS

| Outlet | Headline | Date |
|--------|----------|------|
| Bloomberg | "Claude Code and the Great Productivity Panic of 2026" | Feb 26, 2026 |
| Tom's Hardware | "Claude Code deletes developers' production setup — 2.5 years of records nuked" | Mar 2026 |
| The Register | "Claude devs complain about surprise usage limits" | Jan 5, 2026 |
| The Register | "Anthropic clarifies ban on third-party tool access to Claude" | Feb 20, 2026 |
| SecurityWeek | "Claude Code Flaws Exposed Developer Devices to Silent Hacking" | Feb 2026 |
| The Hacker News | "Claude Code Flaws Allow Remote Code Execution and API Key Exfiltration" | Feb 2026 |
| VentureBeat | "Anthropic cracks down on unauthorized Claude usage by third-party harnesses" | Jan 2026 |
| CNBC | "Defense tech companies are dropping Claude after Pentagon's Anthropic blacklist" | Mar 4, 2026 |
| 9to5Mac | "Claude AI and Code are experiencing log in issues and slow performance" | Mar 11, 2026 |

---

## METHODOLOGY

30+ targeted web searches executed in 7 waves:
1. Core complaint keywords (broken/unusable/frustrated, loops/stuck, deleted/destroyed, ignores instructions, context/memory, subscription cancel, regression)
2. Specific platforms (Bluesky, Mastodon, Threads)
3. Specific voices (Matteo Collina, steipete, Aaron Francis, Jason Miller, DHH, Teresa Torres, Ben Podgursky, Regis Bamba, Nick Davidov, Robin Ebers)
4. Specific incidents (DataTalksClub, OpenCode ban, security vulnerabilities)
5. Competitive switching (Codex, Cursor)
6. Blog/Medium posts
7. Hacker News and Reddit aggregation

**Limitations**:
- Bluesky and Mastodon content is poorly indexed by web search engines — complaint posts likely exist but are invisible to this methodology
- Reddit posts are accessible only via aggregation articles, not direct search
- Engagement numbers are approximate (X does not show exact counts in search previews)
- Some posts may have been deleted between search and report generation
