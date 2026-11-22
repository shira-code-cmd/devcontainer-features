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
