class CreateWebpushSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :webpush_subscriptions do |t|
      t.references :user, foreign_key: true
      t.string     :endpoint, null: false
      t.string     :p256dh,   null: false
      t.string     :auth,     null: false
      t.integer    :status,   null: false, default: 0

      t.timestamps
    end
  end
end
