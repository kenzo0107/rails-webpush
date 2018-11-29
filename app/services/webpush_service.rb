# frozen_string_literal: true

class WebpushService
  def initialize(user_id: nil)
    @user_id = user_id
  end

  def set_id(id)
    @id = id
  end

  def set_title(title)
    @title = title || '運営事務局'
  end

  def set_message(message)
    @message = message
  end

  def set_link(link)
    @link = link || '/'
  end

  def webpush_clients
    # message が設定されてなければ、停止
    if @message.nil?
      return
    end
    today = Time.zone.today
    webpush_subscriptions.each do |ws|
      res = webpush ws
      result = ['success', 'fail']
      # TODO sadd したい
      redis.rpush "message/#{@id}/#{result[res]}", ws.id.to_s
    end
  end

  def webpush(webpush_subscription)
    vapid_public_key = Rails.application.credentials.dig(Rails.env.to_sym, :vapid_public_key)
    vapid_private_key = Rails.application.credentials.dig(Rails.env.to_sym, :vapid_private_key)
    Webpush.payload_send(
      endpoint: webpush_subscription.endpoint,
      p256dh: webpush_subscription.p256dh,
      auth: webpush_subscription.auth,
      ttl: 24 * 60 * 60,
      vapid: {
        public_key: vapid_public_key,
        private_key: vapid_private_key,
        expiration: 1 * 60 * 60
      },
      message: {
        icon: 'https://ishicome-cdn.medpeer.jp/assets/favicon/mstile-for-310x310-df4a2999d2241a9d3d6cf5070af29eb8a3081c6a417334bd68d96bc4b9425b4c.png',
        title: @title,
        body: @message,
        link: @link
      }.to_json
    )
    return 0
  rescue => e
    Rails.logger.error e
    return 1
  end

  private

  def webpush_subscriptions
    @user_id.present? ? WebpushSubscription.where(user_id: @user_id) : WebpushSubscription.all
  end
end
