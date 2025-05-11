class CreateWebhookEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_events do |t|
      t.string :source
      t.json :headers
      t.json :payload
      t.datetime :processed_at
      t.string :status
      t.text :error_message

      t.timestamps
    end
  end
end
