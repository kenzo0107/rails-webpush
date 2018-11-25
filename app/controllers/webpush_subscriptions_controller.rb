# frozen_string_literal: true

class WebpushSubscriptionsController < ApplicationController
  def create
    endpoint = params[:subscription][:endpoint]
    webpush_subscription =
      current_user.webpush_subscriptions.find_or_initialize_by endpoint: endpoint
    webpush_subscription.endpoint = endpoint
    webpush_subscription.p256dh = params[:subscription][:keys][:p256dh]
    webpush_subscription.auth = params[:subscription][:keys][:auth]
    webpush_subscription.save! if webpush_subscription.changed?
    head :ok
  end

  private

  def webpush_subscription_params
    params.require(:subscription).permit(:endpoint, :p256dh, :auth)
  end
end
