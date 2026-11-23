# Dev Container Features

自分の開発環境で共通して使う [Dev Container Features](https://containers.dev/implementors/features/) をまとめたリポジトリです。
共通の VS Code 拡張機能・設定を Feature 側に寄せることで、各プロジェクトの `devcontainer.json` を短く保てます。

## Features

| Feature | 内容 |
| --- | --- |
| [`my-setup`](src/my-setup) | 共通の VS Code 拡張・設定（Python / Ruff 含む）、zsh 環境（starship など）、Git のユーザー設定と GitHub CLI 連携、Node.js、Claude Code、OpenCode と、それぞれの設定・認証情報の永続化マウント |

`my-setup` は VS Code の Python 設定だけを提供します。Python 本体や pip パッケージはベースイメージ／プロジェクト側で用意してください。

`my-setup` の依存 Feature（Node.js・Claude Code・OpenCode）や拡張・マウントは静的に宣言されるため、オプションでは無効化できません。常にすべて入ります。

### 3.x からの移行

`python` / `opencode` / `claude` の各 Feature はソースを削除しました（公開済みの旧バージョンは ghcr に残ります）。`features` から外し、`my-setup` を `:5` 以降にしてください。5.0.0 以降は、ホスト側の環境変数 `MY_DEVCONTAINER_DATA_DIR` と、その配下のディレクトリが必要です（[ホスト側の準備](#ホスト側の準備)を参照）。

## ホスト側の準備

`my-setup` は、認証情報・設定・履歴をホストの専用ディレクトリに bind mount して永続化します（名前付きボリュームは使いません）。ホストの `~/.claude` や `~/.config/gh` を直接マウントしないので、コンテナ内からホスト側の CLI 設定を書き換えられません。

1. ホストで環境変数 `MY_DEVCONTAINER_DATA_DIR` を設定します（**必須**。未設定だとコンテナの起動に失敗します）
   ```bash
   echo 'export MY_DEVCONTAINER_DATA_DIR="$HOME/devcontainer-data"' >> ~/.zshrc
   ```
   macOS で Dock や Spotlight から VS Code を起動する場合は、シェルの環境変数を引き継ぎません。ターミナルから `code .` で起動するか、`launchctl setenv` で設定してください。変更後はコンテナの再ビルドが必要です。
2. マウント元のディレクトリを作成します（無いと起動に失敗します）
   ```bash
   mkdir -p "$MY_DEVCONTAINER_DATA_DIR"/{gh,zsh-history,claude,opencode/{config,data,state}}
   ```

| ホスト（`$MY_DEVCONTAINER_DATA_DIR` 配下） | コンテナ |
| --- | --- |
| `gh` | `/mnt/gh/config` |
| `zsh-history` | `/mnt/zsh-history` |
| `claude` | `/mnt/claude/config` |
| `opencode/config` | `/mnt/opencode/config` |
| `opencode/data` | `/mnt/opencode/data` |
| `opencode/state` | `/mnt/opencode/state` |

Syncthing などで同期する場合は、認証情報（`claude/.credentials.json`、`gh/hosts.yml`）が同期先すべてに渡ること、2 台で同時に使うと履歴 DB（`opencode/data`）が競合・破損しうることに注意してください。

## 使い方

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/python:3.14-trixie",
  "features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/my-setup:5": {
      "gitUserName": "your-name",
      "gitUserEmail": "you@example.com"
    }
  },
  "postCreateCommand": "pip install -r requirements.txt"
}
```

### このリポジトリ自身での利用

このリポジトリの [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json) も、公開済みの Featureを `ghcr.io` から参照して使っています。

- `src/` を変更しても、公開（リリース）されるまでこのリポジトリの開発環境には反映されません
- 開発中の Feature を手元で試したいときは、`features` に `./features/<name>` を指定し、`initializeCommand` で `src/<name>` を `.devcontainer/features/<name>` にコピーしてください（ローカル Feature は `.devcontainer/` 配下にしか置けないため）

  ```jsonc
  "features": { "./features/my-setup": {} },
  "initializeCommand": "rm -rf .devcontainer/features/my-setup && mkdir -p .devcontainer/features && cp -R src/my-setup .devcontainer/features/my-setup"
  ```

- `.devcontainer/features/` を使う場合は `.gitignore` に追加してください

### `my-setup`

共通の開発環境を 1 つにまとめた Feature です。

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

#### zsh

- zsh がなければ apt でインストールします（Debian / Ubuntu 系イメージが対象）
- 有効なオプションに応じて以下を導入します
  - `starship`（公式インストーラで `/usr/local/bin` にインストール）
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
- リモートユーザーの `~/.zshrc` に管理ブロックを追記します（既存の設定は保持し、再実行時はブロックだけ置き換えます）
- オプション `starship` / `autosuggestions` / `syntaxHighlighting`（既定 `true`）で個別に無効化できます

#### git / GitHub CLI

- `gitUserName` / `gitUserEmail` を指定すると、`git config --global` に名前とメールを設定します（空の場合は設定しません）
- ホストの `$MY_DEVCONTAINER_DATA_DIR/gh` を `/mnt/gh/config` に bind mount し、コンテナ内の `~/.config/gh` から symlink します
- `gh` は `ghcr.io/devcontainers/features/github-cli` を依存としてインストールします
- `github.com` / `gist.github.com` の credential helper に `!gh auth git-credential` を設定します（`gh auth setup-git` 相当）
- ホストの `~/.config/gh` とは共有されないため、コンテナ内で一度 `gh auth login` を実行してください
- bind mount は常に有効です。マウント元がないと起動に失敗するため、[ホスト側の準備](#ホスト側の準備)でディレクトリを作成してください
- ホストの `gh` がトークンを OS のキーチェーン（macOS の Keychain など）に保存している場合、共有される `hosts.yml` にはユーザー名しか書かれず、コンテナ内の `gh` は「token invalid」になります。リビルドしても直りません
  - コンテナ内で `gh auth login` を一度実行してください。キーチェーンがないためトークンは `hosts.yml` に平文で保存され、ホストと共有されるのでリビルド後も残ります
  - `git push` だけは、VS Code がホストの認証情報を転送するため `gh` の状態に関係なく動きます

#### 移行（`my-setup:2` + `zsh` + `git-config` から）

`git-config` と `zsh` Feature は廃止しました（公開済みの旧バージョンは ghcr に残ります）。`my-setup:3` に置き換え、`git-config` のオプションをそのまま `my-setup` に渡してください。

#### Claude Code / OpenCode

- 本体は `dependsOn` で導入されます（`anthropics/devcontainer-features/claude-code`、`dirien/devcontainer-features/opencode`）。Node.js も自動で入ります
- ホストの `$MY_DEVCONTAINER_DATA_DIR/claude` を `/mnt/claude/config` に bind mount し、`CLAUDE_CONFIG_DIR=/mnt/claude/config` を設定します（コンテナ内の `~/.claude` は symlink）
  - 状態ファイルは `CLAUDE_CONFIG_DIR` により `$MY_DEVCONTAINER_DATA_DIR/claude/.claude.json`（ホスト側）に保存されるため、ホストの `~/.claude.json` とは共有されません。初回起動時にオンボーディングが表示されることがあります
  - macOS ホストでは認証情報が Keychain に保存されるため、コンテナ内で一度 `/login` してください（`~/.claude/.credentials.json` に保存され、リビルド後も維持されます）
- OpenCode は `$MY_DEVCONTAINER_DATA_DIR/opencode/{config,data,state}` を bind mount し（`data` は履歴 DB で、devcontainer 間で共有されます）、コンテナ作成時に `opencode upgrade 2.3.2 --major` を実行します
- 既存の `~/.claude` を引き継ぐ場合は、Claude を終了してから `cp -a ~/.claude/. "$MY_DEVCONTAINER_DATA_DIR/claude/"` でコピーしてください

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
