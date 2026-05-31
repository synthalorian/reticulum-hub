class CreateNodes < ActiveRecord::Migration[8.1]
  def change
    create_table :nodes do |t|
      t.string :destination_hash
      t.string :name
      t.integer :hops
      t.datetime :last_seen
      t.json :services
      t.json :metadata

      t.timestamps
    end
  end
end
