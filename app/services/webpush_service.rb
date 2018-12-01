# frozen_string_literal: true

class WebpushService
  def initialize(user_id: nil)
    @user_id = user_id
  end

  def broadcast_message(message)
    # 一斉送信
    @message_id = message.id
    @title = message.title || '運営事務局'
    @link = message.link || '/'
    @message = message.message
  end

  def unicast_message(title, link, message)
    # 個別送信
    @title = title || '運営事務局'
    @link = link || '/'
    @message = message
  end

  def webpush_clients
    # message が設定されてなければ、送信停止
    return if @message.nil?

    webpush_subscriptions.each do |ws|
      res = webpush ws
      result = %w[success fail]
      # TODO: sadd したかったけど、 gem 'redis' にはないっぽい。他の redis 関連 gem を試す
      redis.rpush "message/#{@message_id}/#{result[res]}", ws.id.to_s if @message_id.present?
    end
  end

  def webpush(webpush_subscription)
    Webpush.payload_send(
      endpoint: webpush_subscription.endpoint,
      p256dh: webpush_subscription.p256dh,
      auth: webpush_subscription.auth,
      ttl: 24 * 60 * 60,
      vapid: vapid,
      message: message
    )
    0
  rescue => e
    Rails.logger.error e
    1
  end

  private

  def webpush_subscriptions
    @user_id.present? ? WebpushSubscription.where(user_id: @user_id) : WebpushSubscription.all
  end

  def vapid
    {
      public_key: Rails.application.credentials.dig(Rails.env.to_sym, :vapid_public_key),
      private_key: Rails.application.credentials.dig(Rails.env.to_sym, :vapid_private_key),
      expiration: 1 * 60 * 60 # 有効期限 送信後、同じメッセージはこの有効期限まで再通知されない。
    }
  end

  def message
    {
      icon: 'https://ishicome-cdn.medpeer.jp/assets/favicon/mstile-for-310x310-df4a2999d2241a9d3d6cf5070af29eb8a3081c6a417334bd68d96bc4b9425b4c.png',
      title: @title,
      body: @message,
      link: @link
    }.to_json
  end
end
