# Troubleshooting / 故障排查

## Common Problems / 常见问题

### Missing upstream dependencies / 缺少上游依赖
If the workflow loads but stalls before proposal/spec creation or cannot progress through the planned stages, double-check that the required OpenSpec skills (`openspec-propose`, `openspec-verify-change`, `openspec-archive-change`) and recommended `superpowers:*` helpers are available in the host. Refer to `docs/upstream-dependencies.md` for the current baseline.

如果工作流可以加载，但在 proposal/spec 创建前停住，或者无法走完规划阶段，先确认宿主具备必需的 OpenSpec skills（`openspec-propose`、`openspec-verify-change`、`openspec-archive-change`）和推荐的 `superpowers:*` 辅助技能。具体基线见 `docs/upstream-dependencies.md`。

### Wrong local skill directory / 错误的本地 skill 目录
Hosts discover skills from their configured skill directories. Ensure `skill/` is linked or copied into the directory you actually use for Codex, Claude Code, Gemini CLI, or opencode; referencing an old `skills/` path causes discovery failures even though everything else is correct.

各个宿主都会在自己的技能目录里查找 skill。确认你把 `skill/` 链接或复制到了实际使用的目录里；如果还在引用旧的 `skills/` 路径，即便其他步骤都对，也会导致发现失败。

### Missing command-line dependencies / 缺少命令行依赖
The helper scripts assume `git`, `bash`, `python3`, and `rg` are available. Run `./scripts/check-prerequisites.sh` before concluding an install is broken. If the script fails, install those tools or adjust the PATH before retrying.

辅助脚本默认依赖 `git`、`bash`、`python3` 和 `rg`。在判断安装失败前，先执行 `./scripts/check-prerequisites.sh`；如果报错，先补环境或修 PATH。

### Host loads the workflow but external execution is incomplete / 宿主能加载工作流但外部执行不完整
The workflow layer may be present, yet a host-specific external execution path (step 5) still needs validation. Revisit the host-specific `docs/installation/<host>.md`, double-check the `docs/compatibility-matrix.md` entry, and confirm the `workflow-state/audit-log.md` notes the chosen execution mode.

有时工作流层已经加载，但宿主特定的外部执行路径还没验证完。回头检查对应的 `docs/installation/<host>.md`、`docs/compatibility-matrix.md`，并确认 `workflow-state/audit-log.md` 记录了所选执行模式。

### Verification checklist not completed / 验证清单未执行
Before archiving or finishing the branch, make sure you have completed `docs/installation/verify.md`. Failed or skipped verification should be documented in `workflow-state/audit-log.md` and trigger a revisit of the earlier stage (execution, planning, or spec).

在归档或结束分支前，必须完成 `docs/installation/verify.md`。失败或跳过的验证要写进 `workflow-state/audit-log.md`，并把流程拉回前一阶段重新确认。

### Public docs still referencing old layout / 公开文档仍引用旧结构
If you encounter documentation that mentions a top-level `skills/` folder, consider it stale. The public installation unit is `skill/`, and every doc should restate the upstream repo origins to avoid implying vendoring.

如果文档里还提到顶层 `skills/` 文件夹，就把它视为过时内容。公开安装入口是 `skill/`，文档里也应明确说明上游仓库来源，避免让人误以为这里 vendoring 了依赖。
