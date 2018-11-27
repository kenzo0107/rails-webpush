## VAPIDの生成

```
root@91be3e7b5119:/usr/src/app# bin/rails c
Loading development environment (Rails 5.2.1)

irb(main):002:0> vapid_key = Webpush.generate_key
=> #<Webpush::VapidKey:3f9f7e07df98 :public_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx :private_key=yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

irb(main):003:0> vapid_key.public_key
=> "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

irb(main):004:0> vapid_key.private_key
=> "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
```

## serviceworker インストール

```
docker-compose run --rm --no-deps web bundle exec rails g serviceworker:install

create  app/assets/javascripts/manifest.json.erb
create  app/assets/javascripts/serviceworker.js.erb
create  app/assets/javascripts/serviceworker-companion.js
create  config/initializers/serviceworker.rb
append  app/assets/javascripts/application.js
append  config/initializers/assets.rb
insert  app/views/layouts/application.html.erb
create  public/offline.html
```

トップページ作成
```
docker-compose run --rm --no-deps web bundle exec rails g controller top
docker-compose run --rm --no-deps web bundle exec rails g controller article
```

macOS で自己証明書で ServiceWorker を動作させる。
```
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome -
-user-data-dir=/tmp/foo --ignore-certificate-errors --unsafely-treat-insecure-origin-as-secure=https://dev.hoge.test
```

# Sorcery で User ログイン関連処理作成

https://oe526.hatenablog.com/entry/sorcery

## User モデル作成

```
docker-compose run --rm --no-deps web bundle exec rails g sorcery:install
```

```
docker-compose run --rm --no-deps web bundle exec rails g scaffold user email:string crypted_password:string salt:string
```

```
docker-compose run --rm --no-deps web bundle exec rails g controller UserSessions new create destroy
```

## Subscription モデル作成

```
docker-compose run --rm --no-deps web bundle exec rails g scaffold WebpushSubscription
```


```
docker-compose run --rm --no-deps web bundle exec rails c

> message = {
    icon: 'https://example.com/images/demos/icon-512x512.png',
    target_url: '/article',
    title: '運営事務局',
    body: 'こんにちは！'
  }

> WebpushService.new.webpush_clients(message)

> WebpushService.new.webpush_clients("{target_url: '/article', title: '運営事務局', body: 'こんにちは！'}")
```
