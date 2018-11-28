# frozen_string_literal: true

class WebpushService
  def initialize(user_id: nil)
    @user_id = user_id
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
    webpush_subscriptions.each do |webpush_subscription|
      webpush webpush_subscription
    end
  end

  def webpush(webpush_subscription)
    # message が設定されてなければ、停止
    if @message.nil?
      return
    end
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
        icon: 'https://example.com/images/demos/icon-512x512.png',
        title: @title,
        body: @message
        # target_url: @link
      }.to_json
    )
  rescue Pusher::Error => e
    logger.error e
  end

  private

  def webpush_subscriptions
    @user_id.present? ? WebpushSubscription.where(user_id: @user_id) : WebpushSubscription.all
  end
end
