# Spec Triage Analysis

You are analyzing a specification document for VoxCore, a TrinityCore-based WoW private server.

## Your Task
Analyze the following spec and provide a structured assessment.

## Spec Content
{spec_content}

## Project Context
{project_context}

## Required Output (JSON)
Respond with ONLY a JSON object (no markdown fencing):

{{
  "title": "Short title of the spec",
  "complexity": "S|M|L|XL",
  "risk_class": "safe|review-required|restricted",
  "implementation_ready": true|false,
  "target_files": ["list of source files that would need changes"],
  "databases_affected": ["list of databases: world, auth, characters, hotfixes, roleplay"],
  "sql_required": true|false,
  "estimated_loc": 0,
  "summary": "2-3 sentence summary of what this spec does",
  "concerns": ["any risks or issues identified"],
  "domain": "tooling|reports|utilities|gameplay-systems|auth-account|network-protocol|other"
}}

## Risk Classification Guide
- **safe**: Tooling, reports, utilities, non-gameplay scripts, documentation, isolated systems
- **review-required**: Gameplay systems, new features, DB schema additions, UI changes
- **restricted**: Auth/account systems, network protocol, persistence layer, build system, credentials
