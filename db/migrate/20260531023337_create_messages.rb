class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.string :sender_hash
      t.string :recipient_hash
      t.string :subject
      t.text :body
      t.datetime :sent_at
      t.boolean :delivered
      t.boolean :read
      t.string :direction
      t.json :metadata

      t.timestamps
    end
  end
end
