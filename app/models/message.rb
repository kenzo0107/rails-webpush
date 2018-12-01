# frozen_string_literal: true

class Message < ApplicationRecord
  extend Enumerize
  enumerize :status, in: { un_send: 0, sent_test: 1, sent_real_user: 2 }, scope: true
end
