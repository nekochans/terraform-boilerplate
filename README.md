# terraform-boilerplate
Terraformの設計を行う際に雛形となるプロジェクトです。

## 事前準備

### Terraformのインストール
[tfenv](https://github.com/Zordrak/tfenv/blob/master/README.md) の利用を推奨します。

Terraformはマイナーバージョンでも破壊的な変更を行う事があるのでバージョンが気軽に切り替えられる事は必須だからです。

非推奨の機能は次のマイナーバージョンでいきなり削除とかも過去にはあったので、Terraformが警告を無視しない事が非常に大切になります。

`brew install tfenv` でインストールします。

その後以下の手順で設定を行います。

- `tfenv install 0.11.10`
- `tfenv use 0.11.10`
- `terraform --version` で Terraform v0.11.10 が表示されればOK

### AWSのIAMユーザーを作成

`AdministratorAccess` を付与したユーザーを作成して下さい。

アクセスキーでアクセス出来るように設定しておく必要があります。

Terraformはこのアクセスキーを使ってAWSの各種Resourcesを作成・管理します。

### aws_access_key_id, aws_secret_access_keyの設定

Macの場合 `brew install awscli` を実行してaws cliのインストールを行います。

その後、`aws configure --profile nekochans-dev`

対話形式のインターフェースに従い入力します。

```
AWS Access Key ID [None]: `アクセスキーIDを入力`
AWS Secret Access Key [None]: `シークレットアクセスキーを入力`
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

ちなみに aws cli なしでもAWSクレデンシャルを設定する事は可能です。

`~/.aws/credentials` という名前のファイルを作成して以下の内容を設定します。

```
[nekochans-dev]
aws_access_key_id = あなたのアクセスキーID
aws_secret_access_key = あなたのシークレットアクセスキー
```

このプロジェクトではprofile名を `nekochans-dev` としています。

この名前は任意の物でも構いませんが、必ずprofile名を明示的に付けておく事が重要です。

そうしないと複数のAWS環境を管理する際に誤って他の環境に適応してしまう、等の事故が発生する可能性があるからです。

profile名を書き換えた場合、`providers/aws/environments/○○/` 配下の `provider.tf`, `backend.tf` を書き換えて下さい。

### S3Bucketを作成する

`.tfstate` というファイルに実行状態を記録します。（実体はただのJSONファイルです）

このプロジェクトでは `dev-nekochans-tfstate` というS3Bucketがその保存先になります。

この設定は `providers/aws/environments/○○/backend.tf` に記載されています。

S3Bucketはグローバルの名前空間でユニークな名前になっている必要があります。（同じ名前のS3Bucketは作成出来ない）

このプロジェクトを元に設計を行う場合は、この部分を自身が作ったS3Bucketに書き換える必要があります。

実戦では本番環境とステージング・開発環境でAWSアカウントが異なるというケースもあるので、 `backend.tf` はGitの管理対象外とするのも有効です。

### `terraform.tfvars` を配置する

`providers/aws/environments/20-bastion/terraform.tfvars` というファイルを作成し、以下の内容を追記して下さい。

```
ssh_public_key_path = "~/.ssh/dev_nekochans_aws.pem.pub"
```

これはSSH接続を行う為の公開鍵のパスになります。

各自の環境によって異なると思うので、ここも適時書き換えて下さい。

本プロジェクトでは以下のパスに公開鍵と秘密鍵が存在する想定です。

- dev_nekochans_aws.pem
- dev_nekochans_aws.pem.pub

例えば `~/.ssh/config` に以下のように記述すれば `ssh my_aws_stg_bastion_1` で接続する事が可能です。

```
Host my_aws_stg_bastion_1
    HostName 13.115.164.138
    Port 22
    User ec2-user
    IdentityFile ~/.ssh/dev_nekochans_aws.pem
```

## ディレクトリ構成

下記のようなディレクトリ構成になっています。

```
terraform-boilerplate/
  ├ modules/
  │  └ aws/
  └ providers/
     └ aws/
       └ environments/
         ├ 10-network/
         ├ 20-bastion/
```

`providers` の頭の数字に注目して下さい。

`.tfstate` はこれらのディレクトリ配下毎に存在しますが、数字の大きなディレクトリは数字が小さなディレクトリに依存しています。

その為、必ず数字が小さいディレクトリから `terraform apply` を実行する必要があります。

今後このプロジェクトをベースに機能を追加する際も依存関係を意識してディレクトリ名を決める必要があります。

## 設計方針

- 今はAWSのみだが、他のproviderが増えても大丈夫なように `providers/` を作ってあります
- 各moduleには特定のリージョンに依存した値はハードコードしない（AZの名前とか）
- マルチリージョンでの運用にも耐えられるディレクトリ設計

`providers/aws/environments/10-network/main.tf` を見ると分かるのですが、VPCを東京リージョンとバージニア北部リージョンで作成するようにしています。

同じ要領で他のmoduleも複数リージョンに同時作成する事が可能です。

ただしmodule内に特定のリージョンに依存した書き方があった場合、この設計は破綻するので機能追加の際は注意する必要があります。

## 参考資料

### [公式ドキュメント](https://www.terraform.io/docs/providers/aws/index.html)

各Resourcesのパラメータ等はここで確認するのが確実です。

### [Terraform Recommended Practices](https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html)

公式が公開しているベストプラクティス。

設計方針を決める前に一通り見ておく事を推奨します。

### [Terraform Module Registry](https://registry.terraform.io/)

Terraformの開発元である、HashiCorp社が作成したmodule等を見る事が出来る。

基本的にここを参考にすると良いです。

[【モダンTerraform】ベストプラクティスはTerraform Module Registryを参照しよう](http://febc-yamamoto.hatenablog.jp/entry/2018/02/01/090046)

### その他

どの記事も実戦で良く使うテクニックが載っている良記事です。

- [Terraform職人入門: 日々の運用で学んだ知見を淡々とまとめる](https://qiita.com/minamijoyo/items/1f57c62bed781ab8f4d7)
- [Terraformを1年間運用して学んだトラブルパターン4選](https://medium.com/eureka-engineering/terraform%E3%82%921%E5%B9%B4%E9%96%93%E9%81%8B%E7%94%A8%E3%81%97%E3%81%A6%E5%AD%A6%E3%82%93%E3%81%A0%E3%83%88%E3%83%A9%E3%83%96%E3%83%AB%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B34%E9%81%B8-f31b751a14e6)
- [Terraform Best Practices in 2017](https://qiita.com/shogomuranushi/items/e2f3ff3cfdcacdd17f99)
- [同僚に「早く言ってよ〜」と言われたTerraform小技](https://blog.grasys.io/post/kyouhei/tips-of-terraform_target-and-ignore_changes-and-plugin-dir/)
