---
name: ai-dev-grow
description: Guide non-trivial development and bug-fix work in initialized Git projects through optional just-in-time learning, evidence-backed assessment, and a central personal Skill Graph. Use for ai-dev-grow task analysis, Skill Gaps, learning, assessment, and when an initialized project's AGENTS.md requires the ai-dev-grow workflow.
---

# ai-dev-grow

This skill supports Codex and OpenCode. It requires the ai-dev-grow CLI and an initialized Git project.

Use the central ai-dev-grow repository as the only authority for Skill Mastery and Evidence. Never copy the Graph into the current project.

## Resolve context

Run `ai-dev-grow resolve` from the current project before any workflow. If it reports that the project is not initialized, tell the user to run `ai-dev-grow init`; do not invent a project identity.

Use the returned paths instead of assuming where ai-dev-grow is installed.

## Task mode

When the user asks for task analysis or a Skill Gap:

1. Read `task_command_path` and `graph_path` returned by `resolve`.
2. Follow the task command exactly.
3. Treat `project_id` as task provenance only; Mastery remains global.
4. Show only 1–3 decision-relevant Skills. For every Gap or unverified Skill, explain its meaning, use in this task, status basis, delivery risk, and recommended action.
5. Use a specific Skill ID. Never replace the report with a vague statement such as "system design capability is unknown."
6. Present a reasoned task-level recommendation and the user's choices. Learning is optional and skipping it must not block development.
7. Do not write Evidence or modify either repository.

## Learn mode

When the user chooses to learn a Gap or explicitly invokes `/learn`:

1. Read `learn_command_path` and `graph_path` returned by `resolve`.
2. Follow the learn command exactly and keep the material scoped to the current task.
3. Return to the development task after the understanding check.
4. Do not write Evidence, update Mastery, or claim that learning alone proves a level.

## Assess mode

When the user asks to assess a Skill:

1. Read `assess_command_path`, `graph_path`, and the Evidence convention at `<hub_root>/experiences/README.md`.
2. Check the Git status of `hub_root`. Preserve unrelated work; stop if uncommitted changes overlap the Graph or intended Evidence path.
3. Assess only the requested Skill. Insufficient evidence leaves it Unknown.
4. Before writing, show the proposed level, confidence, Evidence summary, and affected central files; obtain confirmation when the user has not already explicitly authorized the assessment write.
5. Write the Evidence into `evidence_dir` with the resolved `project_id`, then update the central Graph as specified by the assess command.
6. Do not update the current business repository except for its existing `.ai-dev-grow/project.yaml`.
7. Do not calculate Derived Mastery.

## Guided development lifecycle

When the initialized project's `AGENTS.md` requires this workflow for a non-trivial development task, bug fix, or refactor:

1. Run Task mode before coding.
2. Before asking for a choice, show the concrete Skill decision information required by Task mode. If no concrete Skill can be tied to the task, do not offer learning for it.
3. For a Gap, offer Learn or direct development. For an unverified Skill, offer Assess, Learn without assuming a level, or direct development. Respect the user's choice.
4. Continue the normal project development workflow after that choice.
5. After implementation and verification, summarize Evidence candidates supported by the delivery.
6. Run Assess mode only after the user confirms the proposed assessment write.

Do not trigger this lifecycle for read-only explanation, trivial text or formatting changes, Git status queries, or when the user explicitly opts out.

If the host blocks access outside the current repository, report the required central path and let the user grant access. Do not weaken Codex or OpenCode permissions.
