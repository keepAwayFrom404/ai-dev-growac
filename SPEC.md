# SPEC — ai-dev-grow

> AI 驱动的开发者学习与工程成长系统。

## 项目目标

把真实开发任务作为成长的燃料，形成一条可验证的最小闭环：

```
真实开发任务
  → /task 分析所需 Skill
  → 查询 Skill Graph
  → 找出能力 Gap
  → 用户选择 /learn 或直接开发
  → 开发与验证
  → 提出 Evidence 候选
  → /assess 验证 Unknown Skill
  → 记录直接 Evidence
  → 更新 Skill Graph
  → 再次 /task
```

## 当前版本：V0.2

V0.2 验证跨项目的 `init → /task → 可选 /learn → 开发 → /assess → Evidence → Graph → /task` 最小闭环：

- Codex 与 OpenCode 通过同一 Agent Skill 使用系统。
- 每个业务 Git 项目通过 `ai-dev-grow init` 创建稳定 `project_id`。
- `/task` 只分析并报告 Gap，不写文件。
- `/learn` 提供面向当前任务的即时学习，用户可选择跳过；学习不写 Evidence 或 Mastery。
- `/assess` 把带 `project_id` 的直接 Evidence 和 Skill Mastery 写回中央 ai-dev-grow 仓库。
- `init` 在业务项目 `AGENTS.md` 中维护一个最小规则区块，引导非简单开发任务进入闭环。
- Derived Mastery 仅定义数据模型，不实现聚合算法。
- `/scan` 仍为空 stub。

## 跨项目架构

`~/ai-dev-grow` 保存个人全局唯一的 Graph、Evidence、命令规范和共享 Skill。安装命令把 Skill 与 CLI 链接到用户级发现目录：

```text
~/.agents/skills/ai-dev-grow -> <ai-dev-grow>/.agents/skills/ai-dev-grow
~/.local/bin/ai-dev-grow     -> <ai-dev-grow>/bin/ai-dev-grow
~/.config/opencode/commands/task.md   -> <ai-dev-grow>/.opencode/commands/task.md
~/.config/opencode/commands/assess.md -> <ai-dev-grow>/.opencode/commands/assess.md
~/.config/opencode/commands/learn.md  -> <ai-dev-grow>/.opencode/commands/learn.md
```

业务项目只保存：

```yaml
version: 1
project_id: "project-a"
```

约束：

- 不在业务项目复制 Skill Graph、Evidence 或 Skill 实现。
- `init` 只追加或更新业务项目 `AGENTS.md` 中带标记的 ai-dev-grow 受管区块，不覆盖已有规则。
- 不自动修改 Codex 或 OpenCode 主配置。
- `project_id` 只标识 Evidence 来源，不切分个人 Mastery。
- 默认从 Git 仓库目录名生成 ID；同名项目使用 `ai-dev-grow init --id <id>` 显式区分。
- V0.2 只支持串行评估写入，不实现并发锁、服务端或数据库。

### 客户端调用

两端均从 `.agents/skills` 发现同一 `SKILL.md`，再通过 `ai-dev-grow resolve` 获取中央数据路径。

- Codex 优先通过自然语言自动触发 Skill，必要时使用 `$ai-dev-grow` 显式调用。Codex 不提供自定义裸 `/task`。
- OpenCode 通过全局薄适配命令提供 `/task`、`/learn` 和 `/assess`；适配层只转发参数并要求加载共享 Skill，不复制工作流规则。

### 引导式开发生命周期

初始化项目的受管规则要求非简单开发、Bug 修复和重构在编码前执行 `/task`。Gap 不构成强制门禁：

- 用户选择学习时执行 `/learn`，完成即时学习和理解检查后返回开发；
- 用户选择跳过时直接开发；
- `unverified` 提供先 `/assess`、先 `/learn` 或直接开发三种选择；学习不得被解释为 Unknown 等于 L0；
- 开发和验证完成后只整理 Evidence 候选，经用户确认才执行 `/assess`。

纯解释、只读检查、简单文案或格式调整、Git 状态查询以及用户明确跳过的任务默认不触发。

## Skill Graph 模型

`skills/graph.yaml` 是唯一权威数据源，由 Domain 和 Skill 两类实体组成。

### Domain

Domain 只负责分类：

- 字段为 `id`、`name`。
- 不维护 Mastery 或 Evidence。
- V0 初始 Domain：Frontend、Backend、AI Engineering、System Design。

### Skill

Skill 是可以被任务引用、评估和积累 Evidence 的能力节点：

- `domain_id` 指向一个 Domain。
- `parent_id` 为 `null` 或指向同一 Domain 内另一个 Skill。
- 通过 `parent_id` 支持任意深度层级，不限制为固定的 Domain → Skill → Sub-skill 三级。
- 任意 Skill 都可以同时拥有子 Skill 和自己的直接 Evidence；非叶子节点不是纯目录。
- 具体 Skill 随真实任务动态增长。

采用扁平 Skill 列表和父引用，而不是递归 YAML，以保持 diff 可读并方便稳定引用。

## Mastery 模型

### 等级

| 值 | 含义 |
|---|---|
| `null` | Unknown：尚无可信等级 |
| `L0` | 已验证为基本不了解 |
| `L1` | Understand：理解，能读懂 |
| `L2` | Apply：能应用，可查资料交付 |
| `L3` | Independent：可独立交付 |

Unknown 不等于 L0。L0 必须有直接 Evidence；不能因为缺少证据就推断为 L0。

### 来源

每个 Skill 使用以下结构：

```yaml
mastery:
  level: null
  source: null
  confidence: null
evidence: []
```

`mastery.source` 的合法值：

| 来源 | 含义 | V0 行为 |
|---|---|---|
| `null` | Unknown，没有可信 Mastery | `/task` 判为 Assess |
| `evidence` | 当前等级由该 Skill 的直接 Evidence 支持 | `/assess` 可以写入 |
| `derived` | 当前等级由子 Skill 聚合推导 | 只保留模型，不计算、不写入 |

一致性约束：

- Unknown 时 `level`、`source`、`confidence` 必须全部为 `null`。
- `source: evidence` 时，`level` 和 `confidence` 必须有值，`evidence` 至少有一项。
- `source: derived` 时，`level` 和 `confidence` 必须有值；V0 不定义其计算规则。
- `confidence` 取值范围为 0.0–1.0，仅表示对当前等级判断的确信度。
- Evidence 是 `experiences/` 文件引用，格式见 `experiences/README.md`。
- 每条 Evidence 包含来源 `project_id`，但不保存业务项目的机器绝对路径。

## V0 Gap 判定规则（三分类）

- 交付场景默认 `required_level = L2`。
- 每个任务所需 Skill 判定为以下三类之一：

| 状态 | 条件 | 动作 |
|---|---|---|
| `unverified` | Graph 中不存在，或 `mastery.level == null` | Assess |
| `satisfied` | `mastery.level >= required_level` | Skip |
| `gap` | `mastery.level < required_level` | Learn |

- `evidence` 和已有合法的 `derived` Mastery 使用相同等级比较规则。
- Graph 中不存在的新 Skill 是 candidate，默认为 Unknown；`/task` 不写回 Graph。
- candidate 记录 `domain_id`，并在存在合适父 Skill 时记录 `parent_id`。

## `/assess` 最小写入规则

- 评估必须针对一个具体 Skill，并产生可复核的直接 Evidence。
- candidate 在获得有效 Evidence 后才加入 Graph。
- `/assess` 只写 `source: evidence`，不更新祖先节点，不产生 Derived Mastery。
- 证据不足时保持 Unknown，不创建 Evidence，也不更新 Graph。
- Graph 和 Evidence 始终写入中央 ai-dev-grow 仓库，业务项目只保留初始化标记。

## `/learn` 最小规则

- `/learn` 必须绑定一个明确 Skill 和当前真实任务，只覆盖本次交付所需知识。
- 输出最小知识、任务内应用方式、理解检查和开发交接。
- 学习是用户选择，不阻塞直接开发。
- 完成学习不等于获得 Mastery，不创建 Evidence，不更新 Graph。
- V0.2 不实现课程系统、题库、FSRS 或复杂 Learning Backlog。

## 未来方向（本期不实现）

- Derived Mastery 聚合算法
- Pattern Library、Learning Backlog
- Reference Repo、MindWiki / CodeGraph CodeContextProvider
- `/scan`
- 技能树可视化
- 多用户同步、云服务与并发写入

## 明确不做

- Web UI
- Database、Vector DB、Graph DB
- FSRS、Multi-Agent
- 复杂 Mastery Score、完整知识图谱
- 一次实现所有 Commands

## 工程原则

- 数据优先使用 Markdown / YAML / JSON
- Git Friendly
- 简单优先，不提前抽象，不为未来需求提前实现基础设施
- 这是一个 Learning Project
