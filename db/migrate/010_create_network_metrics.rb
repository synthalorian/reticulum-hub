class CreateNetworkMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :network_metrics do |t|
      t.string :metric_type, null: false
      t.string :peer_hash
      t.string :interface_name
      t.float :value, null: false
      t.json :metadata
      t.datetime :timestamp, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    add_index :network_metrics, [ :metric_type, :timestamp ]
    add_index :network_metrics, [ :peer_hash, :timestamp ]
    add_index :network_metrics, :interface_name
  end
end
