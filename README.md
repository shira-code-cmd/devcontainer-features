# Dev Container Features

自分の開発環境で共通して使う [Dev Container Features](https://containers.dev/implementors/features/) をまとめたリポジトリです。
共通の VS Code 拡張機能・設定を Feature 側に寄せることで、各プロジェクトの `devcontainer.json` を短く保てます。

## Features

| Feature | 内容 |
| --- | --- |
| [`my-setup`](src/my-setup) | 共通の VS Code 拡張・設定（Prettier、Git 系、Container Tools）と zsh |
| [`python`](src/python) | Python 向けの VS Code 拡張・設定（Python、Ruff） |

`python` Feature は VS Code の設定だけを提供します。Python 本体や pip パッケージはベースイメージ／プロジェクト側で用意してください。

## 使い方

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/python:3.14-trixie",
  "features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/my-setup:2": {},
    "ghcr.io/shira-code-cmd/devcontainer-features/python:1": {},
    "ghcr.io/devcontainers/features/node:2.1.2": {}
  },
  "postCreateCommand": "pip install -r requirements.txt"
}
```

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

### `python`

- VS Code 拡張
  - `ms-python.python`
  - `charliermarsh.ruff`
- VS Code 設定
  - Python の環境マネージャー: `ms-python.python:system`
  - 型チェック: `standard`
  - Python ファイルのフォーマッター: Ruff

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
