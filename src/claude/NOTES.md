## 永続化の仕組み

- ホストの `~/.claude` をコンテナの `/mnt/claude/config` に bind mount します。
- `CLAUDE_CONFIG_DIR=/mnt/claude/config` を設定するため、通常 `~/.claude.json` に保存される状態ファイルも `~/.claude/.claude.json`（ホスト側）に保存されます。ファイル単位の bind mount を使わないので、ホストにファイルが無くても壊れません。
- コンテナ内の `~/.claude` は `/mnt/claude/config` への symlink です。

## 前提

ホストに `~/.claude` ディレクトリが存在する必要があります。`devcontainer.json` の `initializeCommand` で作成してください。

```json
"initializeCommand": "mkdir -p ${localEnv:HOME}/.claude"
```

## 注意

- ホスト側の `~/.claude.json` はコンテナと共有されません（コンテナ用の状態は `~/.claude/.claude.json` に分かれます）。初回起動時にオンボーディングが一度表示されることがあります。
- macOS ホストでは認証情報が Keychain に保存されるため、ホストのログイン状態は引き継がれません。コンテナ内で一度 `/login` すれば `~/.claude/.credentials.json` に保存され、以降のリビルドでも維持されます。
