# 安装验证

在完成手动安装和宿主映射后，用这份清单做一次验证。目标很简单：确认宿主能加载 `opsx-development-workflow`，能访问 `obra/superpowers` 和 `Fission-AI/OpenSpec`，并能触发 [examples/minimal-usage.md](../../../examples/minimal-usage.md) 里的最小工作流。

## 仓库检查

执行：

```bash
find skill -maxdepth 2 -type f | sort
./scripts/check-prerequisites.sh
./scripts/verify-install.sh
```

预期：

- `skill/SKILL.md` 存在
- `skill/references/` 存在
- `skill/assets/` 存在
- `skill/scripts/` 存在
- 辅助脚本返回成功

## 最小验证清单

1. 按对应宿主页面启动宿主，并让它刷新 skill 注册表。
2. 确认 `opsx-development-workflow` 出现在宿主的 skill 列表或等价视图里。
3. 用 [examples/minimal-usage.md](../../../examples/minimal-usage.md) 中的提示文本触发工作流。
4. 检查响应，确认它进入的是 explore、spec、plan 路径，而不是把这次调用当成一次普通 prompt。

## 为什么要做验证

这份清单能证明两件事：

- 宿主确实指向了本仓库中的 OpsX skill
- 该 skill 确实能调用 `obra/superpowers` 和 `Fission-AI/OpenSpec` 来串起工作流阶段

如果任何一步失败，先回到对应宿主的安装说明，确认 skill 路径和宿主配置无误，再判断是不是工作流本身有问题。

## 上游提醒

该 workflow skill 集成的是 `https://github.com/obra/superpowers` 和 `https://github.com/Fission-AI/OpenSpec`；本仓库只记录集成方式，不包含它们的源码。
