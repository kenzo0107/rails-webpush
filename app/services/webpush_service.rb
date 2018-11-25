# frozen_string_literal: true

class WebpushService
  def initialize(user_id: nil)
    @user_id = user_id
  end

  def webpush_clients(message)
    webpush_subscriptions.each do |webpush_subscription|
      webpush webpush_subscription, message
    end
  end

  def webpush(webpush_subscription, message)
    vapid_public_key = Rails.application.credentials.dig(Rails.env.to_sym, :vapid_public_key)
    vapid_private_key = Rails.application.credentials.dig(Rails.env.to_sym, :vapid_private_key)

    Webpush.payload_send(
      message: message,
      endpoint: webpush_subscription.endpoint,
      p256dh: webpush_subscription.p256dh,
      auth: webpush_subscription.auth,
      ttl: 24 * 60 * 60,
      vapid: {
        public_key: vapid_public_key,
        private_key: vapid_private_key,
        expiration: 12 * 60 * 60
      }
    )
  end

  private

  def webpush_subscriptions
    @user_id.present? ? WebpushSubscription.where(user_id: @user_id) : WebpushSubscription.all
  end
end
