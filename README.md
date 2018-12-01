## 起動方法

```
macOS%$ docker-compose up
```

http://localhost:8888 にアクセス

## Web プッシュ送信の大まかな流れ

1. ユーザが Web プッシュ購読 許可する。
2. ユーザがサーバ側から発行されている VAPID の公開鍵を元に 認証情報 (endpoint, p256dh, auth) を発行、ブラウザに登録
3. サーバ側でユーザ情報保存
4. サーバ側でユーザが発行した認証情報を元に Web プッシュ通知送信

## VAPIDの生成

```
macOS%$ docker-compose run --rm --no-deps web bundle exec rails c
root@91be3e7b5119:/usr/src/app#
Loading development environment (Rails 5.2.1)

irb(main):002:0> vapid_key = Webpush.generate_key
=> #<Webpush::VapidKey:3f9f7e07df98 :public_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx :private_key=yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

irb(main):003:0> vapid_key.public_key
=> "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

irb(main):004:0> vapid_key.private_key
=> "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
```

生成された public_key, private_key は credentials に保存

## serviceworker インストール方法

```
macOS%$ docker-compose run --rm --no-deps web bundle exec rails g serviceworker:install

create  app/assets/javascripts/manifest.json.erb
create  app/assets/javascripts/serviceworker.js.erb
create  app/assets/javascripts/serviceworker-companion.js
create  config/initializers/serviceworker.rb
append  app/assets/javascripts/application.js
append  config/initializers/assets.rb
insert  app/views/layouts/application.html.erb
create  public/offline.html
```

## macOS で自己証明書で ServiceWorker を動作させる。

ServiceWorker は以下環境でないと動作しません。
* `localhost`
* 適切なSSL証明書をインストールしたドメイン

自己証明書の場合は以下コマンドでブラウザ起動する必要があります。

```
# 例) Chrome

macOS%$ /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome -
-user-data-dir=/tmp/foo --ignore-certificate-errors --unsafely-treat-insecure-origin-as-secure=https://dev.hoge.test
```

`--ignore-certificate-errors` で証明書のエラーを無視します。

## Sorcery で User ログイン関連処理作成

https://oe526.hatenablog.com/entry/sorcery

```
docker-compose run --rm --no-deps web bundle exec rails g sorcery:install
docker-compose run --rm --no-deps web bundle exec rails g scaffold user email:string crypted_password:string salt:string
docker-compose run --rm --no-deps web bundle exec rails g controller UserSessions new create destroy
```

## scaffold WebpushSubscription 

```
docker-compose run --rm --no-deps web bundle exec rails g scaffold WebpushSubscription
```

## Web プッシュ送信してみる

localhost:8888/messages にアクセスして適当な メッセージを作成して `/messages/:id` にアクセスすると Web プッシュ送信ボタンがあるので押してみて♪
