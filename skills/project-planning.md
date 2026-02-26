---
name: project-planning
description: Rules for planning and managing any type of project.
---

# Project Planning Rules

## General Rule
Always start with a detailed plan before any implementation or code generation.
Never skip the planning phase, even for small tasks.

## Step 1 — Executive Summary
Before anything else, produce a concise executive summary including:
- Project goal and scope
- Target users or stakeholders
- Key technical and business constraints
- Estimated overall timeline
- Main risks identified

## Step 2 — Detailed Plan Structure
Break the project into 4 phases:

1. Discovery & Analysis — requirements, research, technical audit
2. Design & Architecture — UI/UX design, system architecture, database schema
3. Development — frontend, backend, mobile, integrations
4. Delivery — testing, deployment, documentation, handoff

Each phase must include:
- Prioritized tasks (high / medium / low)
- Dependencies between tasks
- Assigned roles (frontend dev, backend dev, designer, DBA, lead, etc.)
- Time estimates per task

## Step 3 — Kanban Board in Notion
After the plan, always create a Kanban board in Notion using the connected connector.
Customize columns based on the project type:

### Web App Project
Columns: Backlog → Design → Frontend → Backend → Review → Testing → Done

### Mobile App Project (Flutter)
Columns: Backlog → Design → Development → Integration → QA → Store Release → Done

### API / Backend Project
Columns: Backlog → Architecture → Development → Testing → Documentation → Deployed → Done

### Design Project
Columns: Brief → Research → Wireframes → UI Design → Review → Delivered → Done

### Business / General Project
Columns: Ideas → To Do → In Progress → Blocked → Review → Done

## Step 4 — Notion Task Properties
Each task created in Notion must have the following properties:
- Title — clear and action-oriented (e.g. "Build authentication API")
- Status — based on the Kanban column
- Priority — High / Medium / Low
- Assignee — role or person responsible
- Start Date — planned start
- Due Date — planned deadline
- Dependencies — linked tasks that must be completed first
- Domain tag — Frontend / Backend / Mobile / Design / DevOps / Database / Business
- Estimate — time estimate in hours or days

## Step 5 — Follow-up
After creating the Kanban board, always ask:
- Are there additional tasks or phases to add?
- Are there constraints or blockers already identified?
- Should Claude generate a technical architecture document next?
