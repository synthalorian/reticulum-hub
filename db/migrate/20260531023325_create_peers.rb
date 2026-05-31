class CreatePeers < ActiveRecord::Migration[8.1]
  def change
    create_table :peers do |t|
      t.string :destination_hash
      t.string :name
      t.datetime :last_seen
      t.float :link_quality
      t.integer :hops
      t.string :status
      t.json :metadata

      t.timestamps
    end
  end
end
