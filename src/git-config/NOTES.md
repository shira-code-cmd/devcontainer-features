## ホスト側の準備

`gh` の認証情報はホストの `~/.config/gh` を bind mount して共有します。
事前にホストで GitHub CLI にログインし、ディレクトリを作成しておいてください。

```bash
gh auth login
mkdir -p ~/.config/gh
```

`~/.config/gh` が存在しない場合、Docker が空のディレクトリを作成するため、コンテナは起動しますが未認証になります。
`initializeCommand` などで事前にディレクトリを作成しておくのがおすすめです。

```jsonc
"initializeCommand": "mkdir -p ${localEnv:HOME}/.config/gh"
```

`github.com` と `gist.github.com` の credential helper には `!gh auth git-credential` が設定されます。
