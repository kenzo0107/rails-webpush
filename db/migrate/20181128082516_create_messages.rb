class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string  :title, null: false
      t.string  :message, null: false
      t.string  :link, null: false
      t.datetime :send_reservation_at
      t.integer  :status, null: false, default: 0

      t.timestamps
    end
  end
end
