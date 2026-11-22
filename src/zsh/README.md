
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
|-----|-----|-----|-----|
| starship | starship プロンプトをインストールして ~/.zshrc で初期化する | boolean | true |
| autosuggestions | zsh-autosuggestions をインストールして ~/.zshrc で読み込む | boolean | true |
| syntaxHighlighting | zsh-syntax-highlighting をインストールして ~/.zshrc で読み込む | boolean | true |

## 対応イメージ

Debian / Ubuntu 系のイメージが対象です（`apt-get` が必要）。

## `~/.zshrc` への追記

リモートユーザーの `~/.zshrc` に以下の管理ブロックを追記します。既存の設定はそのまま残ります。

```zsh
# >>> zsh feature >>>
autoload -Uz compinit && compinit
...
# <<< zsh feature <<<
```

Feature を再実行した場合は、このブロックだけが置き換わります。

## Nerd Font

starship のアイコンを正しく表示するには、ターミナル側で Nerd Font を設定してください。フォントがない場合でも動作しますが、一部の記号が別の文字として表示されます。


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/shira-code-cmd/devcontainer-features/blob/main/src/zsh/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
