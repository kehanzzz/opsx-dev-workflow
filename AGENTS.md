# AGENTS.md

如果当前任务已经被 `opsx-development-workflow` 接管，那么调用任何上游 skill 完成局部职责后，都必须回到 OpsX 主流程。

不要把上游 skill 的默认“下一步”当作整个 workflow 的最终下一步。后续动作以下一阶段定义和当前 `workflow-state` 的 `next_action` 为准。
