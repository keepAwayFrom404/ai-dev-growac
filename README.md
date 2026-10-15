# ai-dev-grow

个人跨项目工程成长系统。它把真实开发任务映射到中央 Skill Graph，通过直接 Evidence 更新个人 Mastery，并让不同项目复用同一份能力状态。

当前 V0.2 支持 Codex 和 OpenCode。

## 安装

```bash
git clone https://github.com/keepAwayFrom404/ai-dev-growac.git ~/ai-dev-grow
cd ~/ai-dev-grow
./bin/ai-dev-grow install
```

安装会创建五个用户级符号链接：

```text
~/.agents/skills/ai-dev-grow -> ~/ai-dev-grow/.agents/skills/ai-dev-grow
~/.local/bin/ai-dev-grow     -> ~/ai-dev-grow/bin/ai-dev-grow
~/.config/opencode/commands/task.md   -> ~/ai-dev-grow/.opencode/commands/task.md
~/.config/opencode/commands/assess.md -> ~/ai-dev-grow/.opencode/commands/assess.md
~/.config/opencode/commands/learn.md  -> ~/ai-dev-grow/.opencode/commands/learn.md
```

确保 `~/.local/bin` 已加入 `PATH`。安装不会修改 Codex 或 OpenCode 的主配置。

## 初始化业务项目

```bash
cd ~/project-a
ai-dev-grow init
```

默认使用 Git 仓库目录名作为项目 ID。存在同名项目时显式指定：

```bash
ai-dev-grow init --id team-project-a
```

初始化会：

- 创建 `.ai-dev-grow/project.yaml`，保存稳定项目 ID；
- 在业务项目根 `AGENTS.md` 追加或更新带 `AI_DEV_GROW` 标记的受管工作流区块；
- 保留该文件已有规则，不复制 Skill Graph、Evidence 或 Mastery。

重复执行 `ai-dev-grow init` 会刷新同一个受管区块，不会重复追加。建议把项目配置和 `AGENTS.md` 一并提交。

## 使用

Codex：

```text
# 初始化项目中的非简单开发和 Bug 修复会由 AGENTS.md 引导触发
实现订单查询缓存和降级

# 自动触发不稳定时显式指定 Skill
$ai-dev-grow task 实现订单查询缓存和降级
$ai-dev-grow learn backend.cache
$ai-dev-grow assess backend.cache
```

OpenCode：

```text
/task 实现订单查询缓存和降级
/learn backend.cache
/assess backend.cache
```

Codex 当前不支持把 Agent Skill 注册为裸 `/task`；OpenCode 的 slash command 是对共享 Skill 的薄适配层。

### 开发与学习选择

对非简单开发、Bug 修复和重构，工作流为：

```text
Task → Skill Gap → 用户选择 Learn 或直接开发 → 开发与验证
     → Evidence 候选 → 用户确认后 Assess → 中央 Graph
```

- `gap`：用户可以先 `/learn`，也可以跳过学习直接开发；学习不是门禁。
- `unverified`：可以先 `/assess`、先 `/learn`，或直接开发；选择学习不表示 Unknown 等于 L0。
- `/learn` 只提供当前任务所需的即时学习和理解检查，不写 Evidence 或 Mastery。
- 开发完成后只生成 Evidence 候选；必须经用户确认才执行 `/assess`。
- 纯解释、只读检查、简单文案/格式调整和 Git 状态查询默认不触发。

检查安装和项目状态：

```bash
ai-dev-grow doctor
ai-dev-grow resolve
```

## 数据边界

- `~/ai-dev-grow/skills/graph.yaml` 是唯一 Mastery 数据源。
- `~/ai-dev-grow/experiences/` 保存跨项目 Evidence。
- 业务项目仅保存稳定的 `project_id`。
- Domain 不维护 Mastery；Derived Mastery 在 V0.2 仍不计算。
