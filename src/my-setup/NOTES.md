## 含まれるもの

- Node.js、Claude Code、OpenCode（`dependsOn` で導入。オプションでは無効化できません）
- ホストの `~/.claude`、`~/.config/opencode`、`~/.local/state/opencode`、`~/.config/gh` の bind mount（ホスト側に事前に作成が必要）
- OpenCode の履歴 DB（`~/.local/share/opencode`）は名前付きボリューム `my-setup-opencode-data` で、同じ Feature を使う devcontainer 間で共有されます（ホストの bind mount 上では SQLite が破損するため）

```json
"initializeCommand": "mkdir -p ${localEnv:HOME}/.config/gh ${localEnv:HOME}/.claude ${localEnv:HOME}/.config/opencode ${localEnv:HOME}/.local/state/opencode"
```

## 旧 Feature からの移行

`python` / `opencode` / `claude` は `my-setup` に統合され、非推奨になりました。`features` から外し、`my-setup` を `:4` にしてください。
