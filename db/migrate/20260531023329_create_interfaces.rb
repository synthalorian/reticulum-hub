class CreateInterfaces < ActiveRecord::Migration[8.1]
  def change
    create_table :interfaces do |t|
      t.string :name
      t.string :interface_type
      t.string :status
      t.json :config
      t.integer :bandwidth_in
      t.integer :bandwidth_out
      t.float :error_rate
      t.integer :uptime
      t.datetime :last_seen
      t.json :metadata

      t.timestamps
    end
  end
end
