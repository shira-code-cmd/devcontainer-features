# Dev Container Features

自分の開発環境で共通して使う [Dev Container Features](https://containers.dev/implementors/features/) をまとめたリポジトリです。
共通の VS Code 拡張機能・設定を Feature 側に寄せることで、各プロジェクトの `devcontainer.json` を短く保てます。

## Features

| Feature | 内容 |
| --- | --- |
| [`my-setup`](src/my-setup) | 共通の VS Code 拡張・設定（Python / Ruff 含む）、zsh 環境（starship など）、Git のユーザー設定と GitHub CLI 連携、Node.js、Claude Code、OpenCode と、それぞれの設定・認証情報のワークスペース内への永続化 |

`my-setup` は VS Code の Python 設定だけを提供します。Python 本体や pip パッケージはベースイメージ／プロジェクト側で用意してください。

`my-setup` の依存 Feature（Node.js・Claude Code・OpenCode）や拡張は静的に宣言されるため、オプションでは無効化できません。常にすべて入ります。

### 3.x からの移行

`python` / `opencode` / `claude` の各 Feature はソースを削除しました（公開済みの旧バージョンは ghcr に残ります）。`features` から外し、`my-setup` を `:6` にしてください。

### 5.x からの移行

6.0.0 でホストからの bind mount を廃止しました。ホスト側の環境変数 `MY_DEVCONTAINER_DATA_DIR` は不要です。データは各ワークスペースの `.devcontainer/.persist/` に保存されます（[データの保存先](#データの保存先)を参照）。

5.x のデータを引き継ぐ場合は、6.0.0 でコンテナを作り直したあと、ホストで次のようにコピーしてください。引き継がない場合は、プロジェクトごとに `gh auth login` と Claude の `/login` をやり直してください。

```bash
cp -a "$MY_DEVCONTAINER_DATA_DIR"/. <ワークスペース>/.devcontainer/.persist/
```

## データの保存先

`my-setup` は、認証情報・設定・履歴をワークスペース内の `.devcontainer/.persist/` に保存します。ホストからの mount も名前付きボリュームも使わないので、ホスト側での準備は要りません。ワークスペースは devcontainer が元々コンテナに見せているフォルダなので、rebuild してもデータは残ります。

```
<ワークスペース>/.devcontainer/.persist/
├── .gitignore        # 中身は「*」。このディレクトリごと git の管理対象から外れる
├── gh/               # ~/.config/gh
├── zsh-history/      # zsh の HISTFILE
├── claude/           # CLAUDE_CONFIG_DIR（~/.claude）
└── opencode/
    ├── config/       # ~/.config/opencode
    ├── data/         # ~/.local/share/opencode
    └── state/        # ~/.local/state/opencode
```

- ビルド時のコンテナには、ワークスペースの場所がまだ分かりません。そのため、上記の各パスはまず固定のアンカー `/mnt/my-setup/data` 経由の symlink にしておきます。コンテナ作成時に `onCreateCommand` の `/usr/local/share/my-setup/init-data.sh` がディレクトリを作り、アンカーをワークスペースへ向けます
- ディレクトリは自身の `.gitignore` で ignore されるため、各リポジトリの `.gitignore` に追記する必要はありません
- データはプロジェクトごとに独立します。プロジェクトごとに一度 `gh auth login` と Claude の `/login` が必要です
- トークンは平文で保存されます。git には入りませんが、`docker build .` のビルドコンテキストや zip にしたフォルダには含まれます。必要なら `.dockerignore` に `.devcontainer/.persist` を追加してください

## 使い方

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/python:3.14-trixie",
  "features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/my-setup:6": {
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
- `~/.config/gh` は `.devcontainer/.persist/gh` を指します（[データの保存先](#データの保存先)）
- `gh` は `ghcr.io/devcontainers/features/github-cli` を依存としてインストールします
- `github.com` / `gist.github.com` の credential helper に `!gh auth git-credential` を設定します（`gh auth setup-git` 相当）
- ホストの `~/.config/gh` とは共有されないため、プロジェクトごとにコンテナ内で一度 `gh auth login` を実行してください。コンテナにはキーチェーンがないため、トークンは `hosts.yml` に平文で保存され、rebuild 後も残ります
- `git push` だけは、VS Code がホストの認証情報を転送するため `gh` の状態に関係なく動きます

#### 移行（`my-setup:2` + `zsh` + `git-config` から）

`git-config` と `zsh` Feature は廃止しました（公開済みの旧バージョンは ghcr に残ります）。`my-setup:3` に置き換え、`git-config` のオプションをそのまま `my-setup` に渡してください。

#### Claude Code / OpenCode

- 本体は `dependsOn` で導入されます（`anthropics/devcontainer-features/claude-code`、`dirien/devcontainer-features/opencode`）。Node.js も自動で入ります
- `CLAUDE_CONFIG_DIR=/mnt/my-setup/data/claude`（実体は `.devcontainer/.persist/claude`）を設定します（コンテナ内の `~/.claude` は symlink）
  - 状態ファイル `.claude.json` もこのディレクトリに保存されるため、ホストの `~/.claude.json` とは共有されません。初回起動時にオンボーディングが表示されることがあります
  - macOS ホストでは認証情報が Keychain に保存されるため、プロジェクトごとにコンテナ内で一度 `/login` してください（`.credentials.json` に保存され、rebuild 後も維持されます）
- OpenCode の設定・履歴 DB・状態は `.devcontainer/.persist/opencode/{config,data,state}` に保存されます。コンテナ作成時に `opencode upgrade 2.3.2 --major` を実行します
- 既存の `~/.claude` を引き継ぐ場合は、Claude を終了してから `cp -a ~/.claude/. <ワークスペース>/.devcontainer/.persist/claude/` でコピーしてください

## 開発

Feature の追加・変更後は、リポジトリの devcontainer 内でテストできます。

```bash
# 単一 Feature の自動テスト
devcontainer features test --skip-scenarios -f my-setup -i mcr.microsoft.com/devcontainers/base:debian .

# グローバルシナリオ（複数 Feature の組み合わせ）
devcontainer features test --global-scenarios-only .
```

CI では以下を実行します。テストは Debian 系イメージの一般ユーザーでのみ行っており、root ユーザーや Ubuntu 系イメージでの動作は確認していません。

- `devcontainer-feature.json` の検証
- 各 Feature の自動テスト（`mcr.microsoft.com/devcontainers/base:debian`）
- `test/_global` のシナリオテスト

## リリース

1. `src/<feature>/devcontainer-feature.json` の `version` を更新する
2. main ブランチにマージする
3. GitHub Actions の `Release dev container features & Generate Documentation` を手動実行する
4. 初回公開した Feature は GHCR のパッケージ設定で public にする

Feature は `ghcr.io/shira-code-cmd/devcontainer-features/<feature>:<major>` で参照できます。
