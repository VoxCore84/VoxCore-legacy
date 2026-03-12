# Spell Interaction Querying Reference

*Absorbed from Desktop/discord-reply.txt — originally a Discord reply explaining how to cross-reference spell interactions.*

---

**Getting all spells for a class/spec** — union these sources:
- `SkillLineAbility` — class skill lines (Warrior = 840, Mage = 904, etc.)
- `SpecializationSpells` — spec-specific spell assignments
- Trait tree chain: `SkillLineXTraitTree` > `TraitNode` > `TraitNodeEntry` > `TraitDefinition.SpellID` for the modern talent trees

**SpellWork-style data** comes from joining: `SpellEffect`, `SpellMisc`, `SpellClassOptions`, `SpellAuraOptions`, `SpellCategories`. You can browse all of these on wago.tools/db2.

**Finding interactions** is the harder part. There's no single source — interactions live in multiple places:

1. **SpellClassMask overlap** — `SpellClassOptions` gives each spell an identity bitmask within its family (`SpellClassSet`). Any `SpellEffect` with a matching `EffectSpellClassMask` targets it. This catches aura modifiers (ADD_FLAT_MODIFIER, ADD_PCT_MODIFIER, etc.). Caveat: ~80% of spells across all classes have all-zero masks, so this only catches a subset of interactions.

2. **EffectTriggerSpell** — direct trigger chains in `SpellEffect`. Follow these to find what a spell fires off.

3. **SpellLabel** — Blizzard's modern grouping system (~139K entries). Some effects target a label ID instead of a class mask.

4. **spell_proc** (TC world DB, not DB2) — proc definitions that wire spells together on the server side.

5. **C++ spell scripts** — a big chunk of interactions are hardcoded in the spell script files, not discoverable from DB2 at all.

## Practical Workflow

For catching missed interactions (like the Brutal Finish case):
1. Look up the spell's `SpellClassOptions` mask
2. Query the same `SpellClassSet` for all effects whose `EffectSpellClassMask` overlaps
3. Chase `EffectTriggerSpell` chains
4. Check `spell_proc`
5. For script-level stuff, grep the C++ source

Not perfect, but it catches the modifier/proc interactions that are easiest to miss.
