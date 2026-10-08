# Evidence 约定

`experiences/` 保存 `/assess` 产生的可复核直接证据。Skill Graph 只保存文件引用，不复制完整评估过程。

## 文件命名

```text
YYYY-MM-DD-<skill-slug>-<short-id>.md
```

同一 Skill 可以有多条 Evidence；文件名必须稳定且不覆盖已有记录。

## 最小格式

```markdown
---
id: evidence-<stable-id>
skill_id: <skills/graph.yaml 中的 Skill id>
assessed_at: YYYY-MM-DD
method: <assessment | delivery | review>
level: <L0 | L1 | L2 | L3>
confidence: <0.0–1.0>
---

# Evidence：<Skill name>

## Context
<评估背景或任务>

## Observation
<可复核的实际表现或产物>

## Rationale
<为何证据支持该 level>

## Limitations
<证据没有覆盖的范围>
```

## 约束

- 一条 Evidence 只直接支持一个 `skill_id`。
- `level` 必须来自实际评估结果；证据不足时不创建文件，Skill 保持 Unknown。
- Evidence 可以支持非叶子 Skill；该 Skill 同时拥有子 Skill 不影响其直接 Evidence。
- Evidence 不自动提升父 Skill、子 Skill或兄弟 Skill。
- V0 不使用 Evidence 聚合 Derived Mastery。
