# ai-dev-grow

个人跨项目工程成长系统。它把真实开发任务映射到中央 Skill Graph，通过直接 Evidence 更新个人 Mastery，并让不同项目复用同一份能力状态。

当前 V0.1 支持 Codex 和 OpenCode。

## 安装

```bash
git clone https://github.com/keepAwayFrom404/ai-dev-growac.git ~/ai-dev-grow
cd ~/ai-dev-grow
./bin/ai-dev-grow install
```

安装会创建四个用户级符号链接：

```text
~/.agents/skills/ai-dev-grow -> ~/ai-dev-grow/.agents/skills/ai-dev-grow
~/.local/bin/ai-dev-grow     -> ~/ai-dev-grow/bin/ai-dev-grow
~/.config/opencode/commands/task.md   -> ~/ai-dev-grow/.opencode/commands/task.md
~/.config/opencode/commands/assess.md -> ~/ai-dev-grow/.opencode/commands/assess.md
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

初始化只创建 `.ai-dev-grow/project.yaml`，不会复制 Skill Graph，也不会修改业务项目的 `AGENTS.md`。
该文件只包含稳定项目 ID，建议随业务仓库提交。

## 使用

Codex：

```text
# 通常可以直接用自然语言触发
分析这个任务的 Skill Gap：实现订单查询缓存和降级

# 自动触发不稳定时显式指定 Skill
$ai-dev-grow task 实现订单查询缓存和降级
$ai-dev-grow assess backend.cache
```

OpenCode：

```text
/task 实现订单查询缓存和降级
/assess backend.cache
```

Codex 当前不支持把 Agent Skill 注册为裸 `/task`；OpenCode 的 slash command 是对共享 Skill 的薄适配层。

检查安装和项目状态：

```bash
ai-dev-grow doctor
ai-dev-grow resolve
```

## 数据边界

- `~/ai-dev-grow/skills/graph.yaml` 是唯一 Mastery 数据源。
- `~/ai-dev-grow/experiences/` 保存跨项目 Evidence。
- 业务项目仅保存稳定的 `project_id`。
- Domain 不维护 Mastery；Derived Mastery 在 V0.1 仍不计算。
