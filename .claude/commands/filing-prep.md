---
allowed-tools: Bash(python3:*), Bash(python:*), Read, Grep, Glob, Agent, Write, Edit
description: Prepare a legal filing — pull requirements, search evidence, draft narrative with citations, flag gaps
---

# Filing Prep

Prepare a draft legal filing by pulling form requirements, searching the case archive for relevant evidence, and drafting the narrative sections with citations.

## Arguments

The user specifies:
- `/filing-prep DD7050` — DoD IG Whistleblower Reprisal complaint
- `/filing-prep AFBCMR` — AFBCMR application (DD Form 149)
- `/filing-prep NPDB dispute` — NPDB report challenge
- `/filing-prep HIPAA complaint` — HHS OCR complaint
- `/filing-prep OSC supplement` — OSC complaint update
- `/filing-prep congressional [recipient]` — Congressional inquiry letter

## Pipeline

### Phase 1: Requirements
Read the specific filing requirements for the requested form type. Key regulatory references:
- **DD 7050**: 10 U.S.C. 1034, DoDD 7050.06, DAFI 90-301
- **DD 149**: 10 U.S.C. 1552, DAFI 36-2603
- **NPDB**: 45 C.F.R. Part 60
- **HIPAA**: 45 C.F.R. Parts 160, 164

### Phase 2: Evidence Gathering
Fan out agents to search the case archive for evidence supporting each required element:

1. **case-researcher agent**: Search `Case_Reference/` and FINAL docs for relevant evidence
2. **Grep the email extracts**: `11_EMAILS/Takeout_Extracted/Legal/txt/` and `UNOPENED_EVIDENCE/txt/`
3. **Check the cross-reference report**: `11_EMAILS/CROSS_REFERENCE_REPORT.md`
4. **Read the discrepancy analysis**: `00_COMPLETE_DISCREPANCY_ANALYSIS.md`

### Phase 3: Draft Narrative
Write the narrative section of the filing:
- Use formal legal writing style (not argumentative, not casual)
- Cite specific evidence for every factual claim: `(See Exhibit [X], [description])`
- Organize chronologically within each legal element
- Keep paragraphs focused — one claim per paragraph with its supporting evidence
- Use regulatory language that matches the filing requirements

### Phase 4: Exhibit List
Generate a proposed exhibit list:
```
Exhibit A: [document name] — [what it proves]
Exhibit B: [document name] — [what it proves]
```
Map each exhibit to its file path in the case archive.

### Phase 5: Gap Analysis
Flag anything that's:
- Claimed in the narrative but has no exhibit
- Referenced in the archive but not included in the draft
- Needed but not yet obtained (e.g., FOIA responses, records from mil email)

## Output

Write the draft to: `C:/Users/atayl/Desktop/Case_Reference/13_ANALYSIS_AND_BRIEFS/DRAFT_[filing_type]_[date].md`

```
# DRAFT — [Filing Type]
Prepared: [date]
Status: DRAFT — requires attorney review

## I. Summary of Complaint / Request for Relief
[1-2 paragraph summary]

## II. Statement of Facts
[Chronological narrative with exhibit citations]

## III. Legal Basis
[Statutory and regulatory framework]

## IV. Evidence of [specific legal element]
[For each required element, narrative + citations]

## V. Relief Requested
[Specific, measurable relief]

## VI. Proposed Exhibit List
| Exhibit | Document | Source Path | Proves |
|---------|----------|-------------|--------|

## VII. Gaps / Items Needed
- [ ] [missing item]
```

## Rules

- ALWAYS mark output as DRAFT requiring attorney review
- Do not fabricate or embellish facts — only cite what's in the archive
- Use the evidence rating from `/evidence-gap` — don't cite WEAK evidence as if it's STRONG
- For reconstructed accounts, note they are "Complainant's account" not established fact
- Flag any potential CUI/PII that should be handled carefully in the filing
