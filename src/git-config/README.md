
# Git Config (git-config)

Git のユーザー設定と GitHub CLI の認証連携

## Example Usage

```json
"features": {
    "ghcr.io/shira-code-cmd/devcontainer-features/git-config:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| gitUserName | git config --global user.name に設定する値（空の場合は設定しない） | string | - |
| gitUserEmail | git config --global user.email に設定する値（空の場合は設定しない） | string | - |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/shira-code-cmd/devcontainer-features/blob/main/src/git-config/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
