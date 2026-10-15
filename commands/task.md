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
   - 不要展开完整技能树，只到本任务真正用得到的节点；最终只展示 **1–3 个**最影响当前决策的 Skill，优先展示 `gap` 和 `unverified`。
   - Skill 必须使用具体、稳定的 ID。不得用“系统设计能力”“后端能力”等宽泛分类代替具体 Skill。
3. **Skill Resolution**：把发现的 Skill 匹配回 `skills/graph.yaml` 已有 `id`：
   - 匹配上 → `source: graph`。
   - 匹配不上 → `source: candidate`，同时给出所属 `domain_id`；若存在最接近的已知父 Skill，再给出 `parent_id`，否则为 `null`。
   - `parent_id` 只能指向 Skill，不能指向 Domain。
4. **Required Level**：为每个 Skill 给出 `required_level`，默认 `L2`。
5. **Current Mastery**：读取 `mastery.level`、`mastery.source` 与 `mastery.confidence`；candidate 的当前 Mastery 为 Unknown。
6. **Gap Analysis**：按三分类判定（见下）。
7. **出报告**：按下方模板**仅打印到对话，不落盘**。
   - 报告注明当前 `project_id`，但不创建项目级 Mastery。
   - 每个 `gap` 或 `unverified` 必须说明能力含义、本任务用途、状态依据、不处理的任务风险和推荐动作。
   - 推荐动作必须有理由；可以推荐 Learn、Assess 或直接开发，但不能替用户做最终选择。
   - 如果无法说明某个 Skill 在本任务中的具体用途，就不要把它列为 Gap，也不要据此询问是否学习。
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

### 决策相关 Skill（最多 3 个）
| Skill | 能力含义 | 本任务用途 | Required / Current | 状态依据 | 不处理的风险 | 推荐动作 |
|---|---|---|---|---|---|---|
| backend.task-persistence | 异步任务状态持久化 | 判断保存失败发生在写入、事务还是状态回写 | L2 / Unknown | Graph 中无直接 Evidence | 可能只修表象，遗漏状态不一致 | 先直接排查；修复后 Assess |
| backend.observability.log-tracing | 日志与调用链定位 | 用任务 ID 关联容器日志和持久化记录 | L2 / Unknown | candidate，尚未评估 | 无法稳定定位失败边界 | 可直接开发；交付后 Assess |
| backend.transaction-consistency | 事务一致性 | 判断保存操作是否被提交或回滚 | L2 / L1 | evidence，低于 Required | 可能误判持久化成功条件 | 可选 Learn 后开发 |

### Gap Analysis
- Learn（gap）：backend.transaction-consistency（L1 → L2）
- Assess（unverified）：backend.task-persistence、backend.observability.log-tracing

### 任务级建议
推荐直接排查并修复，因为日志、复现和测试本身可以形成 Evidence；事务一致性知识可以按需先学，不作为修复门禁。

请选择：
1. 先 `/learn backend.transaction-consistency`，再开发
2. 先评估一个 Unknown Skill
3. 直接开发，完成后再整理 Evidence 候选
```

## 边界

- 不修改 `skills/graph.yaml`。
- 不创建任务文件、不写 Evidence。
- candidate 仅存在于本次报告；只有后续 `/assess` 才能在取得 Evidence 后把它写入 Graph。
- 不根据子 Skill 临时计算或回写父 Skill 的 Derived Mastery。
- 不在业务项目中复制 `skills/graph.yaml` 或创建项目级 Mastery。
- `/task` 不把 Gap 变成强制学习门禁；用户始终可以直接继续开发。
- 不允许只说“相关能力未知”后要求用户选择；必须先展示具体 Skill 及其决策信息。
