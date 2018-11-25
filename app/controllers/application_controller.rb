# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :vapid_public_key
  def vapid_public_key
    vpk = Rails.application.credentials.dig(Rails.env.to_sym, :vapid_public_key)
    @decoded_vapid_public_key ||= Base64.urlsafe_decode64(vpk).bytes
  end
end
