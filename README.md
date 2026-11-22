# Dev Container Features

自分の開発環境で共通して使う [Dev Container Features](https://containers.dev/implementors/features/) をまとめたリポジトリです。
共通の VS Code 拡張機能・設定を Feature 側に寄せることで、各プロジェクトの `devcontainer.json` を短く保てます。

## Features

| Feature | 内容 |
| --- | --- |
| [`git-config`](src/git-config) | Git のユーザー設定と GitHub CLI の認証連携 |
| [`my-setup`](src/my-setup) | 共通の VS Code 拡張・設定（Prettier、Git 系、Container Tools）と zsh |
| [`zsh`](src/zsh) | starship・自動提案・シンタックスハイライト付きの zsh 環境 |
| [`python`](src/python) | Python 向けの VS Code 拡張・設定（Python、Ruff） |
| [`opencode`](src/opencode) | OpenCode 本体と、設定・データの永続化マウント |
| [`claude`](src/claude) | Claude Code 本体と、設定・認証情報の永続化マウント |

`python` Feature は VS Code の設定だけを提供します。Python 本体や pip パッケージはベースイメージ／プロジェクト側で用意してください。

## 使い方

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/python:3.14-trixie",
  "features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/git-config:1": {
      "gitUserName": "your-name",
      "gitUserEmail": "you@example.com"
    },
    "ghcr.io/shira-code-cmd/devcontainer-features/my-setup:2": {},
    "ghcr.io/shira-code-cmd/devcontainer-features/zsh:1": {},
    "ghcr.io/shira-code-cmd/devcontainer-features/python:1": {},
    "ghcr.io/shira-code-cmd/devcontainer-features/opencode:1": {},
    "ghcr.io/shira-code-cmd/devcontainer-features/claude:2": {},
    "ghcr.io/devcontainers/features/node:2.1.2": {}
  },
  "initializeCommand": "mkdir -p ${localEnv:HOME}/.config/gh ${localEnv:HOME}/.claude",
  "postCreateCommand": "pip install -r requirements.txt"
}
```

### `git-config`

- `gitUserName` / `gitUserEmail` を指定すると、`git config --global` に名前とメールを設定します（空の場合は設定しません）
- ホストの `~/.config/gh` を `/mnt/gh/config` に bind mount し、コンテナ内の `~/.config/gh` から symlink します
- `gh` は `ghcr.io/devcontainers/features/github-cli` を依存としてインストールします
- `github.com` / `gist.github.com` の credential helper に `!gh auth git-credential` を設定します（`gh auth setup-git` 相当）
- ホスト側で `gh auth login` 済みである必要があります。`~/.config/gh` がない場合は未認証のまま起動します
- `initializeCommand` で `~/.config/gh` を作成しておくと、Docker が root 所有の空ディレクトリを作るのを防げます
- ホストの `gh` がトークンを OS のキーチェーン（macOS の Keychain など）に保存している場合、共有される `hosts.yml` にはユーザー名しか書かれず、コンテナ内の `gh` は「token invalid」になります。リビルドしても直りません
  - コンテナ内で `gh auth login` を一度実行してください。キーチェーンがないためトークンは `hosts.yml` に平文で保存され、ホストと共有されるのでリビルド後も残ります
  - `git push` だけは、VS Code がホストの認証情報を転送するため `gh` の状態に関係なく動きます

### `my-setup`

- VS Code 拡張
  - `ms-azuretools.vscode-containers`
  - `esbenp.prettier-vscode`
  - `mhutchie.git-graph`
  - `donjayamanne.githistory`
  - `eamodio.gitlens`
- VS Code 設定
  - デフォルトフォーマッター: Prettier
  - 保存時フォーマット: 有効
  - Linux のデフォルトターミナル: zsh
- zsh がなければ apt でインストールします（Debian / Ubuntu 系イメージが対象）
- シェルの設定（starship・プラグインなど）は [`zsh`](#zsh) Feature を使います

### `zsh`

- zsh がなければ apt でインストールします（Debian / Ubuntu 系イメージが対象）
- 有効なオプションに応じて以下を導入します
  - `starship`（公式インストーラで `/usr/local/bin` にインストール）
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
- リモートユーザーの `~/.zshrc` に管理ブロックを追記します（既存の設定は保持し、再実行時はブロックだけ置き換えます）
- VS Code の Linux デフォルトターミナルを zsh に設定します
- オプション `starship` / `autosuggestions` / `syntaxHighlighting` で個別に無効化できます

### `python`

- VS Code 拡張
  - `ms-python.python`
  - `charliermarsh.ruff`
- VS Code 設定
  - Python の環境マネージャー: `ms-python.python:system`
  - 型チェック: `standard`
  - Python ファイルのフォーマッター: Ruff

### `opencode`

- OpenCode 本体は `ghcr.io/dirien/devcontainer-features/opencode` でインストールします（`dependsOn` で自動的に入るため、併記は不要です）
- `ghcr.io/devcontainers/features/common-utils` も依存として入ります
- コンテナ作成時に `opencode upgrade 2.3.2 --major` を実行して V2 に更新します
- 以下のホスト側ディレクトリを bind mount し、設定・データを永続化します
  - `~/.config/opencode`
  - `~/.local/share/opencode`
  - `~/.local/state/opencode`
- コンテナ内の `~/.config/opencode` などは `/mnt/opencode/*` への symlink になります
- `${localEnv:HOME}` を使うため、ホストのホームディレクトリ配下に上記ディレクトリが必要です。このリポジトリの devcontainer では `initializeCommand` で作成しています
- 別プロジェクトで使う場合は、事前にホスト側で以下を実行してください

  ```bash
  mkdir -p ~/.config/opencode ~/.local/share/opencode ~/.local/state/opencode
  ```

### `claude`

- Claude Code 本体は `ghcr.io/anthropics/devcontainer-features/claude-code` でインストールします（`dependsOn` で自動的に入るため、併記は不要です）
- **Node.js が必要です**。`mcr.microsoft.com/devcontainers/javascript-node` のように Node.js が入ったイメージを使うか、`ghcr.io/devcontainers/features/node` を併記してください（`python` Feature と同様に、ランタイムはベースイメージ／プロジェクト側で用意する方針です。`1.x` までは Node.js も自動で入れていましたが、テストと構築が遅くなるため `2.0.0` で外しました）
- ホストの `~/.claude` を `/mnt/claude/config` に bind mount し、`CLAUDE_CONFIG_DIR=/mnt/claude/config` を設定します
- コンテナ内の `~/.claude` は `/mnt/claude/config` への symlink になります
- 通常 `~/.claude.json` に保存される状態ファイルは、`CLAUDE_CONFIG_DIR` により `~/.claude/.claude.json`（ホスト側）に保存されます
  - Claude Code はこのファイルを一時ファイル経由の rename で更新するため、ファイル単位の bind mount や symlink とは相性が悪く、この方式にしています
  - そのため、ホストの `~/.claude.json` はコンテナと共有されません。初回起動時にオンボーディングが表示されることがあります
- macOS ホストでは認証情報が Keychain に保存されるため、ログイン状態は引き継がれません。コンテナ内で一度 `/login` すると `~/.claude/.credentials.json` に保存され、以降のリビルドでも維持されます
- 別プロジェクトで使う場合は、事前にホスト側で以下を実行するか、`initializeCommand` で作成してください

  ```bash
  mkdir -p ~/.claude
  ```

## 開発

Feature の追加・変更後は、リポジトリの devcontainer 内でテストできます。

```bash
# 単一 Feature の自動テスト
devcontainer features test --skip-scenarios -f my-setup -i debian:latest .

# グローバルシナリオ（複数 Feature の組み合わせ）
devcontainer features test --global-scenarios-only .
```

CI では以下を実行します。

- `devcontainer-feature.json` の検証
- 各 Feature の自動テスト（Debian / Ubuntu / devcontainers base）
- `test/_global` のシナリオテスト

## リリース

1. `src/<feature>/devcontainer-feature.json` の `version` を更新する
2. main ブランチにマージする
3. GitHub Actions の `Release dev container features & Generate Documentation` を手動実行する
4. 初回公開した Feature は GHCR のパッケージ設定で public にする

Feature は `ghcr.io/shira-code-cmd/devcontainer-features/<feature>:<major>` で参照できます。
