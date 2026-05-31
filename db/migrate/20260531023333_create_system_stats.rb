class CreateSystemStats < ActiveRecord::Migration[8.1]
  def change
    create_table :system_stats do |t|
      t.float :cpu_percent
      t.float :memory_percent
      t.integer :bandwidth_in
      t.integer :bandwidth_out
      t.integer :uptime
      t.integer :peer_count
      t.integer :interface_count
      t.json :metadata

      t.timestamps
    end
  end
end
