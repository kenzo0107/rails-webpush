# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :vapid_public_key

  def vapid_public_key
    vpk = Rails.application.credentials.dig(Rails.env.to_sym, :vapid_public_key)
    @decoded_vapid_public_key ||= Base64.urlsafe_decode64(vpk).bytes
  end

  private
    def not_authenticated
      redirect_to login_path, alert: 'ログインしてください'
    end
end
