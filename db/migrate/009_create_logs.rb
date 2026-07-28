class CreateLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :logs do |t|
      t.string :source, null: false, default: "rnsd"
      t.string :level, null: false, default: "info"
      t.text :message, null: false
      t.text :metadata
      t.datetime :timestamp, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :logs, [ :source, :level ]
    add_index :logs, :timestamp
  end
end
