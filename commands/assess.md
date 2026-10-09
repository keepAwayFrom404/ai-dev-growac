# /assess — Evidence → Skill Graph

评估当前已初始化项目中的一个具体 Skill，把可复核的直接 Evidence 和 Mastery 写入中央 ai-dev-grow 仓库。

## 输入

```text
/assess <skill-id> [评估目标或可验证材料]
```

- `skill-id` 可以是 Graph 中已有 Skill，也可以是 `/task` 发现的 candidate。
- 信息不足以完成有效评估时，先向用户补充提问，不得猜测等级或伪造 Evidence。
- 执行前通过 `ai-dev-grow resolve` 取得 `project_id`、中央 Graph 和 Evidence 路径；项目未初始化时停止。

## 工作流

```
Skill Resolution → Assessment → Evidence Record → Graph Update → Result
```

1. **Skill Resolution**
   - 已有 Skill：读取其 `domain_id`、`parent_id` 和当前 Mastery。
   - candidate：确认稳定的 `id`、`name`、`domain_id` 和 `parent_id`；`parent_id` 只能指向已有 Skill，也可以为 `null`。
2. **Assessment**
   - 围绕该 Skill 本身验证，不以子 Skill 的等级替代当前 Skill 的直接评估。
   - 产出 `L0 | L1 | L2 | L3` 和 `confidence`。
   - Unknown 不是评估等级；证据不足时保持 Unknown，不写 Evidence、不更新 Graph。
3. **Evidence Record**
   - 按 `experiences/README.md` 创建一条可复核的 Evidence 文件。
   - Evidence 必须说明评估方法、观察结果、等级理由和局限。
   - Evidence 必须记录当前项目的 `project_id`，但不得记录机器绝对路径。
4. **Graph Update**
   - candidate 先作为 Skill 加入 `skills/graph.yaml`。
   - 更新目标 Skill 的 `mastery.level`、`mastery.source: evidence`、`mastery.confidence` 和 `evidence` 引用。
   - 保留该 Skill 之前仍有效的 Evidence 引用。
   - 不修改 Domain Mastery，因为 Domain 没有 Mastery。
   - 不更新父 Skill，不计算或写入 `source: derived`。
   - Graph 和 Evidence 都写入中央 ai-dev-grow 仓库；业务项目只保留 `.ai-dev-grow/project.yaml`。
5. **Result**
   - 报告 Evidence 路径、Graph 变更和仍然存在的局限。
   - 提示可以重新运行 `/task`，让最新直接 Mastery 参与 Gap 判定。

## 一致性约束

- `mastery.level == null` 时，`source` 和 `confidence` 必须为 `null`。
- `mastery.source == evidence` 时，`level`、`confidence` 必须有值，且 `evidence` 至少有一项。
- `mastery.source == derived` 为数据模型保留值；V0 不实现 Derived Mastery 聚合算法，也不由 `/assess` 写入。
- Skill 可以同时拥有子 Skill 和自己的直接 Evidence，二者互不覆盖。
- Evidence 只能支持其声明的 `skill_id`；不能隐式提升祖先或兄弟 Skill。

## Graph 写入示例

```yaml
mastery:
  level: L2
  source: evidence
  confidence: 0.8
evidence:
  - experiences/<evidence-file>.md
```

## 边界

- 不实现自动出题系统、复杂评分模型或 Derived Mastery 聚合。
- 不修改 `/learn`、Learning Backlog 或其他未来模块。
- 没有足够证据时宁可保持 Unknown，不把 Unknown 写成 L0。
- V0.1 不处理并发评估；多个项目的 `/assess` 必须串行写入中央 Graph。
