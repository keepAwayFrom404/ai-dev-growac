# /learn — Gap → Just-in-time Learning → Development

围绕当前真实开发任务，对一个明确的 Skill Gap 进行最小、即时学习，然后返回开发流程。学习是用户可选项，不得阻塞用户直接开发。

## 输入

```text
/learn <skill-id> [当前任务或希望重点学习的内容]
```

执行前必须通过 `ai-dev-grow resolve` 取得 `project_id`、`graph_path` 和中央命令路径。项目未初始化时停止。

## 工作流

```text
Gap → User Choice → Learning Goal → Minimal Guidance → Check → Development
```

1. **确认选择**：仅在用户明确选择学习或直接调用 `/learn` 时进入；否则允许直接开发。
2. **Skill Resolution**：读取 Graph 中的 Skill；candidate 使用 `/task` 报告中的稳定 ID、Domain 和父 Skill 上下文，但不写入 Graph。
3. **Learning Goal**：结合当前任务，把目标限制为一个可在本次交付中应用和验证的能力点。
4. **Minimal Guidance**：提供完成任务所需的最小概念、关键决策、常见风险和一个贴近当前代码的练习或预测问题。
5. **Check**：通过简短复述、代码判断、方案选择或小练习检查理解；这不是 Mastery 评估。
6. **Development Handoff**：总结本次开发要应用的原则，然后继续原开发任务。

## 输出模板

```markdown
## Learning：<skill-id>

### 本次目标
<一个可应用、可验证的学习目标>

### 最小知识
<只覆盖当前任务需要的概念与决策>

### 在当前任务中怎么用
<对应到即将修改的代码、配置或验证方式>

### 理解检查
<一个简短问题或小练习>

### 开发交接
<接下来开发时要遵守和验证的要点>
```

## 边界

- `/learn` 不写 Evidence、不更新 Graph、不改变 Mastery。
- 学习完成不等于通过 `/assess`；只有后续真实表现和可复核 Evidence 才能支持 Mastery。
- 不创建课程系统、题库、FSRS 或复杂 Learning Backlog。
- 不强迫用户学习；用户可随时选择跳过并直接开发。
