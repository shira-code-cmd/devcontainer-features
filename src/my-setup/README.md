
# My Setup (my-setup)

自分の共通開発環境（VS Code拡張・設定・zsh・git/gh連携・Claude Code・OpenCode・Python）

## Example Usage

```json
"features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/my-setup:6": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| gitUserName | git config --global user.name に設定する値（空の場合は設定しない） | string | - |
| gitUserEmail | git config --global user.email に設定する値（空の場合は設定しない） | string | - |
| starship | starship プロンプトをインストールして ~/.zshrc で初期化する | boolean | true |
| autosuggestions | zsh-autosuggestions をインストールして ~/.zshrc で読み込む | boolean | true |
| persistHistory | zsh のコマンド履歴をワークスペース内（.devcontainer/.persist）に保存し、コンテナを作り直しても引き継ぐ | boolean | true |
| syntaxHighlighting | zsh-syntax-highlighting をインストールして ~/.zshrc で読み込む | boolean | true |

## Customizations

### VS Code Extensions

- `ms-azuretools.vscode-containers`
- `esbenp.prettier-vscode`
- `mhutchie.git-graph`
- `donjayamanne.githistory`
- `eamodio.gitlens`
- `ms-python.python`
- `charliermarsh.ruff`

## 含まれるもの

- Node.js、Claude Code、OpenCode（`dependsOn` で導入。オプションでは無効化できません）
- gh・zsh 履歴・Claude Code・OpenCode の設定と認証情報を、ワークスペース内の `.devcontainer/.persist/` に永続化する仕組み。ホストからの mount は使わず、ホスト側の準備も不要です
  - ディレクトリは自身の `.gitignore`（`*`）で git の管理対象から外れます
  - データはプロジェクトごとに独立します。プロジェクトごとに一度 `gh auth login` と Claude の `/login` が必要です

## 5.x からの移行

6.0.0 でホストからの bind mount（`MY_DEVCONTAINER_DATA_DIR`）を廃止しました。5.x のデータを引き継ぐ場合は、6.0.0 でコンテナを作り直したあと、ホストで `cp -a "$MY_DEVCONTAINER_DATA_DIR"/. <ワークスペース>/.devcontainer/.persist/` を実行してください。

## 旧 Feature からの移行

`python` / `opencode` / `claude` は `my-setup` に統合され、非推奨になりました。`features` から外し、`my-setup` を `:6` にしてください。


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/shira-code-cmd/devcontainer-features/blob/main/src/my-setup/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
