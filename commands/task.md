# /task — Task → Skill Gap

分析当前已初始化项目中的真实开发任务，对照中央 Skill Graph 找出能力 Gap。
`/task` 本身只产出 Gap 报告，不记录 Evidence、不更新 Graph；报告完成后由用户选择是否先 `/learn`，随后可以继续真实开发。

## 输入

用户提供真实开发任务描述：`/task <任务描述>`

执行前必须通过 `ai-dev-grow resolve` 取得 `project_id`、`graph_path` 和中央命令路径。项目未初始化时停止，并提示运行 `ai-dev-grow init`。

## 工作流

```
Task → Task Understanding → Skill Discovery → Skill Resolution
     → Required Level → Current Mastery → Gap Analysis
```

1. **Task Understanding**：理解任务目标、范围、交付物（1–3 句摘要）。
2. **Skill Discovery**：把任务分解为所需技能，展开到**「对完成本任务有决策价值」的最小粒度**。
   - 允许发现 Graph 中尚不存在的 **candidate Skill**。
   - Skill 可以是任意层级，且非叶子 Skill 也可以是本任务直接需要的能力。
   - 不要展开完整技能树，只到本任务真正用得到的节点。
3. **Skill Resolution**：把发现的 Skill 匹配回 `skills/graph.yaml` 已有 `id`：
   - 匹配上 → `source: graph`。
   - 匹配不上 → `source: candidate`，同时给出所属 `domain_id`；若存在最接近的已知父 Skill，再给出 `parent_id`，否则为 `null`。
   - `parent_id` 只能指向 Skill，不能指向 Domain。
4. **Required Level**：为每个 Skill 给出 `required_level`，默认 `L2`。
5. **Current Mastery**：读取 `mastery.level`、`mastery.source` 与 `mastery.confidence`；candidate 的当前 Mastery 为 Unknown。
6. **Gap Analysis**：按三分类判定（见下）。
7. **出报告**：按下方模板**仅打印到对话，不落盘**。
   - 报告注明当前 `project_id`，但不创建项目级 Mastery。
8. **用户选择**：存在 Gap 时明确提供以下两种等价可选路径，不替用户决定：
   - 先 `/learn <skill-id>`，完成即时学习后开发；
   - 跳过学习，直接开发。跳过不得阻塞当前任务。
   对 `unverified` Skill 提供先 `/assess`、先 `/learn` 或直接开发三种选择；选择学习不代表 Unknown 是 L0。

## Gap 判定（三分类）

- `unverified`：Graph 中不存在，或 `mastery.level == null` → **Assess**。
- `satisfied`：`mastery.level >= required_level` → **Skip**。
- `gap`：`mastery.level < required_level` → **Learn**。

> Unknown 不是 L0。`null` 表示没有可信等级；L0 表示有直接 Evidence 支持的“基本不了解”。
>
> `mastery.source` 只说明当前等级来自直接 Evidence 还是派生结果，不改变等级比较规则。V0 不计算 Derived Mastery，只读取已有合法值。

## 输出模板

```markdown
## Skill Gap 分析：<任务标题>

Project：<project_id>

### 任务理解
<1–3 句>

### Skill Discovery（最小粒度）
| Skill | 来源 | Required | Current | Mastery Source | 状态 |
|---|---|---|---|---|---|
| frontend.react                    | graph     | L2 | Unknown | —        | 🔶 assess |
| frontend.react.state-management   | candidate | L2 | Unknown | —        | 🔶 assess |
| frontend.javascript               | graph     | L2 | L1      | evidence | ❌ learn   |
| frontend.typescript               | graph     | L2 | L2      | evidence | ✅ skip    |

### Gap Analysis
- Skip（satisfied）：frontend.typescript
- Learn（gap）：frontend.javascript（L1 → L2）
- Assess（unverified）：frontend.react、frontend.react.state-management

### 下一步
- Skip → 直接可用
- Learn → 用户可选：先 `/learn <skill-id>`，或跳过学习直接开发
- Assess → 用户可选：先 `/assess <skill-id>`、先 `/learn <skill-id>`，或直接开发
```

## 边界

- 不修改 `skills/graph.yaml`。
- 不创建任务文件、不写 Evidence。
- candidate 仅存在于本次报告；只有后续 `/assess` 才能在取得 Evidence 后把它写入 Graph。
- 不根据子 Skill 临时计算或回写父 Skill 的 Derived Mastery。
- 不在业务项目中复制 `skills/graph.yaml` 或创建项目级 Mastery。
- `/task` 不把 Gap 变成强制学习门禁；用户始终可以直接继续开发。
