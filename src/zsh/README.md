
# Zsh (zsh)

starship・自動提案・シンタックスハイライト付きの zsh 環境

## Example Usage

```json
"features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/zsh:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
| --- | --- | --- | --- |
| starship | starship プロンプトをインストールして ~/.zshrc で初期化する | boolean | true |
| autosuggestions | zsh-autosuggestions をインストールして ~/.zshrc で読み込む | boolean | true |
| syntaxHighlighting | zsh-syntax-highlighting をインストールして ~/.zshrc で読み込む | boolean | true |

## Customizations

### VS Code Settings

- `terminal.integrated.defaultProfile.linux`: `zsh`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/shira-code-cmd/devcontainer-features/blob/main/src/zsh/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
