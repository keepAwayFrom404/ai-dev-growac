# AGENTS.md — ai-dev-grow 工作约束

## 项目定位

这是一个**个人学习 / 工程成长系统**，不是线上服务、不是业务代码。
核心产出是结构化的 Markdown / YAML 数据，以及约束 AI 行为的斜杠指令（commands）。

## V0 边界（硬约束）

当前实现跨项目最小闭环：项目 `init` → `/task` → Skill Gap → `/assess` → 中央 Evidence → 中央 Skill Graph → 其他项目 `/task`。

**明确禁止实现**（本期一律不做）：

- Web UI、Database、Vector DB、Graph DB
- FSRS、Multi-Agent
- 复杂 Mastery Score、完整知识图谱
- 一次实现所有 Commands（`/scan`、`/learn` 保持空 stub；`/assess` 仅负责直接 Evidence 写入）
- 为未来需求提前实现基础设施

Derived Mastery 只保留数据模型，V0 不实现聚合算法或自动写入。

## 跨项目边界

- `skills/graph.yaml` 与 `experiences/` 始终保存在 ai-dev-grow 中，是个人全局唯一数据源。
- 业务项目只允许创建 `.ai-dev-grow/project.yaml`，不得复制 Graph 或保存项目级 Mastery。
- Codex 与 OpenCode 共用 `.agents/skills/ai-dev-grow/SKILL.md`。
- OpenCode 的 `.opencode/commands/task.md` 与 `assess.md` 只能作为共享 Skill 的薄适配层，不得复制业务规则。
- 初始化脚本不得覆盖目标项目现有 `AGENTS.md`、Agent 配置或同名文件。
- V0.1 只支持串行写入中央 Graph，不实现并发服务或锁基础设施。

## 工作流铁律

在**非简单实现**之前，必须按以下顺序，且**等用户确认后才 Coding**：

1. 先分析问题
2. 给出最小方案
3. 说明关键设计决策与 trade-off
4. 列出会修改的文件
5. 等待确认后再动手

**不要一次性把整个项目实现完。**

## 工程原则

- 数据优先 Markdown / YAML / JSON
- Git Friendly（diff 可读、人工可维护）
- 简单优先，不提前抽象
- 单文件 ≤ 500 行，函数 ≤ 50 行（如将来写代码）

## 核心数据文件

| 文件 | 作用 |
|------|------|
| `skills/graph.yaml` | Skill Graph，唯一权威数据源 |
| `commands/task.md` | `/task` 指令：Task → Skill Gap |
| `commands/assess.md` | `/assess` 指令：直接 Evidence → Skill Graph |
| `experiences/` | 可复核的直接 Evidence |
| `.agents/skills/ai-dev-grow/SKILL.md` | Codex/OpenCode 共用入口 |
| `bin/ai-dev-grow` | 用户安装、项目初始化与环境诊断 |
| `.opencode/commands/` | OpenCode `/task`、`/assess` 薄适配层 |
| `learning/backlog.yaml` | Learning Backlog（未来） |
| `patterns/` | Pattern Library（未来） |
| `references/` | Reference Repo（未来） |

## 文档同步（强制）

改动代码 / 命令 / 数据结构后，必须同步对应文档：
- 改 Skill Graph 结构 → 更新 SPEC.md 与 AGENTS.md 概览
- 改命令流程 → 更新 commands 文件与命令列表
- 改 Gap 规则 → 更新 SPEC.md 的判定规则段
- 改 Evidence 结构 → 更新 experiences/README.md 与 SPEC.md
- 改安装或初始化行为 → 更新 README.md、SPEC.md 与对应测试
