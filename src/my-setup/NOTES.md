## 含まれるもの

- Node.js、Claude Code、OpenCode（`dependsOn` で導入。オプションでは無効化できません）
- ホストの環境変数 `MY_DEVCONTAINER_DATA_DIR` 配下のディレクトリ（`gh`、`zsh-history`、`claude`、`opencode/{config,data,state}`）の bind mount（**必須**。ホスト側に事前に作成が必要）。名前付きボリュームは使いません

```bash
mkdir -p "$MY_DEVCONTAINER_DATA_DIR"/{gh,zsh-history,claude,opencode/{config,data,state}}
```

## 旧 Feature からの移行

`python` / `opencode` / `claude` は `my-setup` に統合され、非推奨になりました。`features` から外し、`my-setup` を `:5` 以降にしてください。5.0.0 以降はホスト側の環境変数 `MY_DEVCONTAINER_DATA_DIR` が必要です。
