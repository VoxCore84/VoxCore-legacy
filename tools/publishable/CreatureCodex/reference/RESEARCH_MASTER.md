# CreatureCodex Reference Research — Master Index

> Compiled March 2026. 21 repos downloaded, 60+ surveyed. All repos in `reference/addons/`.

## Downloaded Reference Repos (21 total, ~190MB)

### Tier 1 — Direct Feature Sources (borrow from these first)

| Repo | Size | Language | What to Borrow |
|------|------|----------|---------------|
| **Datamine** (Ghostopheles) | 7.5M | Lua | Hidden client DB2 data access, creature data caching, tooltip enrichment |
| **hero-dbc** (herotc) | 17M | Lua | DB2 spell data packaged as addon Lua tables — THE pattern for our DB2 enrichment |
| **Setaccio** (sirikfoll) | 1.4M | Java | WPP text parser for creature spell timers/cooldowns — predecessor to our mission |
| **idTip** (silverwind) | 189K | Lua | 12.x TooltipDataProcessor hooks, clean/minimal tooltip modification |
| **ClassicBestiary** | 699K | Lua | Creature-to-spell mapping data structure, tooltip integration for creature abilities |
| **slpp** (SirAnthony) | 121K | Python | Lua↔Python parser for processing SavedVariables externally |

### Tier 2 — UI/UX Patterns

| Repo | Size | Language | What to Borrow |
|------|------|----------|---------------|
| **LibDFramework** (Details!) | 2.8M | Lua | CoolTip tooltips, scrollbox widgets, tab buttons, chart rendering |
| **OneWoW_Suite** (MichinMigugin) | 121M | Lua | Unified settings engine, catalog browser, notes system, alt tracker, GUI library |
| **ViragDevTool** | 231K | Lua | Tree view UI for nested Lua tables — inform spell chain visualization |
| **MobStats** (refaim) | 522K | Lua | Creature data display in tooltips (health, level, faction, classification) |
| **wow-tooltipdatainspector** (kemayo) | 108K | Lua | Raw 12.x tooltip data structure inspector |
| **DevForge** (hatdragon) | 11M | Lua | In-game developer tooling, runtime inspection patterns |

### Tier 3 — Pipeline/Tools

| Repo | Size | Language | What to Borrow |
|------|------|----------|---------------|
| **WoWtoolsParser** (Ketho) | 176K | Lua | wow.tools CSV → Lua table conversion |
| **py-wow-hotfixes** (Ghostopheles) | 163K | Python | DBCache.bin reader — relevant to our hotfix pipeline |
| **wow-build-tools** (McTalian) | 28M | Go | Addon build/release pipeline (low priority for us) |

## Not Downloaded — Reference Only (survey results)

### Creature AI & SmartAI Tools

| Repo | Stars | Why It Matters |
|------|-------|---------------|
| [BAndysc/WoWDatabaseEditor](https://github.com/BAndysc/WoWDatabaseEditor) | 530 | Premier SmartAI IDE — our export format must be compatible |
| [azerothcore/Keira3](https://github.com/azerothcore/Keira3) | 397 | Web-based TC DB editor with creature_template_spell support |
| [trickerer/Trinity-Bots](https://github.com/trickerer/Trinity-Bots) | 541 | NPC companion AI with spell selection/priority logic |
| [NotCoffee418/TrinityCreator](https://github.com/NotCoffee418/TrinityCreator) | 180 | Creature template SQL generation patterns |
| [jasper-rietrae2/SAI-Editor](https://github.com/jasper-rietrae2/SAI-Editor) | 47 | SmartAI event type enums and action mappings |

### Spell Data & Analysis

| Repo | Stars | Why It Matters |
|------|-------|---------------|
| [simulationcraft/simc](https://github.com/simulationcraft/simc) | 1528 | Gold standard spell chain/trigger relationship modeling |
| [WoWAnalyzer/WoWAnalyzer](https://github.com/WoWAnalyzer/WoWAnalyzer) | 566 | Spell chain viz, trigger resolution, combat log parsing |
| [TrinityCore/WowPacketParser](https://github.com/TrinityCore/WowPacketParser) | 497 | Canonical creature_template_spell extraction from sniffs |
| [wowdev/WoWDBDefs](https://github.com/wowdev/WoWDBDefs) | 293 | Authoritative DB2 schema definitions for all spell tables |

### UI Frameworks & References

| Repo | Stars | Why It Matters |
|------|-------|---------------|
| [WeakAuras/WeakAuras2](https://github.com/WeakAuras/WeakAuras2) | 1427 | LibSerialize+LibDeflate for data export, dynamic group layouts |
| [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source) | 930 | Official Blizzard FrameXML — the authoritative UI reference |
| [Questie/Questie](https://github.com/Questie/Questie) | 1063 | Large in-addon database architecture for thousands of records |
| [Total-RP/Total-RP-3](https://github.com/Total-RP/Total-RP-3) | 45 | Player-to-player data sync protocol (chunked addon messages) |
| [Ketho/vscode-wow-api](https://github.com/Ketho/vscode-wow-api) | 209 | VS Code IntelliSense for WoW Lua API development |

### Data Pipeline & Export

| Repo | Stars | Why It Matters |
|------|-------|---------------|
| [WeakAuras/WeakAuras-Companion](https://github.com/WeakAuras/WeakAuras-Companion) | 170 | External app ↔ SavedVariables sync pattern |
| [SafeteeWoW/LibDeflate](https://github.com/SafeteeWoW/LibDeflate) | 109 | Pure Lua compression for addon channel data transfer |
| [simulationcraft/simc-addon](https://github.com/simulationcraft/simc-addon) | 66 | Copy-paste export string pattern |
| [kamoo1/Kamoo-s-TSM-App](https://github.com/kamoo1/Kamoo-s-TSM-App) | 26 | External Python writing into SavedVariables |
| [Sarjuuk/aowow](https://github.com/Sarjuuk/aowow) | 224 | Self-hosted Wowhead clone — web UI for creature spell data |
| [Upload-Academy/azerothcore-daisy](https://github.com/Upload-Academy/azerothcore-daisy) | 36 | YAML-driven creature_template_spell extraction |

### Eluna Script Collections

| Repo | Stars | Why It Matters |
|------|-------|---------------|
| [Isidorsson/Eluna-scripts](https://github.com/Isidorsson/Eluna-scripts) | 99 | Largest Eluna collection — reference for our server handlers |
| [ElunaLuaEngine/Scripts](https://github.com/ElunaLuaEngine/Scripts) | 69 | Official Eluna examples |
| [azerothcore/eluna-ts](https://github.com/azerothcore/eluna-ts) | 32 | TypeScript-to-Lua Eluna transpiler |

### Other Notable Tools

| Repo | Stars | Why It Matters |
|------|-------|---------------|
| [Marlamin/wow.tools.local](https://github.com/Marlamin/wow.tools.local) | 165 | Already in our pipeline |
| [Shauren/WowClientDB2MySQLTableGenerator](https://github.com/Shauren/WowClientDB2MySQLTableGenerator) | 12 | DB2 → MySQL schema auto-generation |
| [Ghostopheles/LibSchematic](https://github.com/Ghostopheles/LibSchematic) | — | Visual scripting framework for addons |
| [morrowchristian/wow-savedvariables-analytics-dashboard](https://github.com/morrowchristian/wow-savedvariables-analytics-dashboard) | 1 | Web dashboard from SV files — could visualize CreatureCodex data |

## Top 10 Actionable Borrowing Priorities

1. **hero-dbc pattern** — Package DB2 spell data as static Lua tables. Users regenerate from CSVs. Zero server round-trips for spell metadata
2. **idTip 12.x tooltip hooks** — Add CreatureCodex data to native creature tooltips ("5 spells captured, 3 new")
3. **Setaccio timer algorithm** — Extract spell cooldown intervals from WPP text for our wpp_import.py
4. **slpp Python parser** — Process CreatureCodex SavedVariables externally for analytics/reporting
5. **ViragDevTool tree view** — Inform spell trigger chain visualization (expandable tree UI)
6. **LibDeflate + LibSerialize** — If we add GM-to-GM data sharing via addon channel
7. **WoWDatabaseEditor SmartAI format** — Validate our SmartAI export SQL is import-compatible
8. **OneWoW settings architecture** — Unified settings panel pattern for growing config options
9. **ClassicBestiary tooltip pattern** — Show known creature abilities on mouseover
10. **WeakAuras export string** — Compress+encode captured data for clipboard sharing

## Key Strategic Insight

**CreatureCodex has no real competitor.** ClassicBestiary is the only vaguely similar concept (static, Classic-only, read-only). No other project combines:
- Server-side C++ spell hooks
- Client-side visual scraping
- Live observation → SQL export pipeline
- Dual-path DB2 enrichment (server query + local CSV)

The niche is genuine and uncontested.
