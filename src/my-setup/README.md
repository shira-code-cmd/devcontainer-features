
# My Setup (my-setup)

自分の共通開発環境（VS Code拡張・設定・zsh・git/gh連携・Claude Code・OpenCode・Python）

## Example Usage

```json
"features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/my-setup:4": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| gitUserName | git config --global user.name に設定する値（空の場合は設定しない） | string | - |
| gitUserEmail | git config --global user.email に設定する値（空の場合は設定しない） | string | - |
| starship | starship プロンプトをインストールして ~/.zshrc で初期化する | boolean | true |
| autosuggestions | zsh-autosuggestions をインストールして ~/.zshrc で読み込む | boolean | true |
| persistHistory | zsh のコマンド履歴を volume に保存し、コンテナを作り直しても引き継ぐ | boolean | true |
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



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/shira-code-cmd/devcontainer-features/blob/main/src/my-setup/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
