---
name: ai-dev-grow
description: Analyze real development tasks against a central personal Skill Graph, assess unknown skills with evidence, and reuse mastery across initialized Git projects. Use when the user requests ai-dev-grow task analysis, skill gaps, or skill assessment.
---

# ai-dev-grow

This skill supports Codex and OpenCode. It requires the ai-dev-grow CLI and an initialized Git project.

Use the central ai-dev-grow repository as the only authority for Skill Mastery and Evidence. Never copy the Graph into the current project.

## Resolve context

Run `ai-dev-grow resolve` from the current project before either workflow. If it reports that the project is not initialized, tell the user to run `ai-dev-grow init`; do not invent a project identity.

Use the returned paths instead of assuming where ai-dev-grow is installed.

## Task mode

When the user asks for task analysis or a Skill Gap:

1. Read `task_command_path` and `graph_path` returned by `resolve`.
2. Follow the task command exactly.
3. Treat `project_id` as task provenance only; Mastery remains global.
4. Do not write Evidence or modify either repository.

## Assess mode

When the user asks to assess a Skill:

1. Read `assess_command_path`, `graph_path`, and the Evidence convention at `<hub_root>/experiences/README.md`.
2. Check the Git status of `hub_root`. Preserve unrelated work; stop if uncommitted changes overlap the Graph or intended Evidence path.
3. Assess only the requested Skill. Insufficient evidence leaves it Unknown.
4. Before writing, show the proposed level, confidence, Evidence summary, and affected central files; obtain confirmation when the user has not already explicitly authorized the assessment write.
5. Write the Evidence into `evidence_dir` with the resolved `project_id`, then update the central Graph as specified by the assess command.
6. Do not update the current business repository except for its existing `.ai-dev-grow/project.yaml`.
7. Do not calculate Derived Mastery.

If the host blocks access outside the current repository, report the required central path and let the user grant access. Do not weaken Codex or OpenCode permissions.
