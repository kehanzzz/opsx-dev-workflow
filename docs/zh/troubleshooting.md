# 故障排查

## 常见问题

### 缺少上游依赖

如果工作流可以加载，但在 proposal 或 spec 创建前停住，或者无法走完规划阶段，先确认宿主具备必需的 OpenSpec skills（`openspec-propose`、`openspec-verify-change`、`openspec-archive-change`）和推荐的 `superpowers:*` 辅助技能。具体基线见 `upstream-dependencies.md`。

### 本地 skill 目录错误

各个宿主都会在自己的 skill 目录里查找能力。确认你把 `skill/` 链接或复制到了实际使用的目录里；如果还在引用旧的 `skills/` 路径，即便其他步骤都对，也会导致发现失败。

### 缺少命令行依赖

辅助脚本默认依赖 `git`、`bash`、`python3` 和 `rg`。在判断安装失败前，先执行 `./scripts/check-prerequisites.sh`；如果报错，先补环境或修 PATH。

### 宿主能加载工作流但外部执行不完整

有时工作流层已经加载，但宿主特定的外部执行路径还没验证完。回头检查对应的 `docs/zh/installation/<host>.md`、`compatibility-matrix.md`，并确认 `workflow-state/audit-log.md` 记录了所选执行模式。

### 验证清单未执行

在归档或结束分支前，必须完成 `docs/zh/installation/verify.md`。失败或跳过的验证要写进 `workflow-state/audit-log.md`，并把流程拉回前一阶段重新确认。

### 公开文档仍引用旧结构

如果文档里还提到顶层 `skills/` 文件夹，就把它视为过时内容。公开安装入口是 `skill/`，文档里也应明确说明上游仓库来源，避免让人误以为这里 vendoring 了依赖。
