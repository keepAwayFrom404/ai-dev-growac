## ai-dev-grow 工作流（受管规则）

当本 Git 项目存在 `.ai-dev-grow/project.yaml` 时，Codex 和 OpenCode 必须对非简单开发任务、Bug 修复和重构使用 `ai-dev-grow` Skill：

1. 开始编码前运行 `ai-dev-grow resolve`，读取中央 `/task` 规则并完成 Skill Gap 分析。
2. 如果存在 `gap`，明确让用户自由选择：
   - 先执行 `/learn <skill-id>`，再继续开发；或
   - 跳过学习，直接继续开发。跳过不应阻塞任务。
3. 如果存在 `unverified`，让用户选择先 `/assess`、先 `/learn` 或直接开发；选择学习不得把 Unknown 当作 L0，也不得暗示已有等级。
4. 完成开发和验证后，整理本次交付可支持的 Evidence 候选；只有用户确认后才执行 `/assess` 并写入中央 Graph。
5. 不得在业务项目复制 Skill Graph、Evidence 或项目级 Mastery。

以下任务默认不触发该流程：纯解释或只读检查、简单文案/格式调整、Git 状态查询，以及用户明确要求跳过 ai-dev-grow 的任务。
