## 含まれるもの

- Node.js、Claude Code、OpenCode（`dependsOn` で導入。オプションでは無効化できません）
- gh・zsh 履歴・Claude Code・OpenCode の設定と認証情報を、ワークスペース内の `.devcontainer/.persist/` に永続化する仕組み。ホストからの mount は使わず、ホスト側の準備も不要です
  - ディレクトリは自身の `.gitignore`（`*`）で git の管理対象から外れます
  - データはプロジェクトごとに独立します。プロジェクトごとに一度 `gh auth login` と Claude の `/login` が必要です

## 5.x からの移行

6.0.0 でホストからの bind mount（`MY_DEVCONTAINER_DATA_DIR`）を廃止しました。5.x のデータを引き継ぐ場合は、6.0.0 でコンテナを作り直したあと、ホストで `cp -a "$MY_DEVCONTAINER_DATA_DIR"/. <ワークスペース>/.devcontainer/.persist/` を実行してください。

## 旧 Feature からの移行

`python` / `opencode` / `claude` は `my-setup` に統合され、非推奨になりました。`features` から外し、`my-setup` を `:6` にしてください。
