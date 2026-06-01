class AddLocationToPeers < ActiveRecord::Migration[8.1]
  def change
    add_column :peers, :latitude, :float
    add_column :peers, :longitude, :float
    add_column :peers, :location_name, :string
    add_index :peers, [:latitude, :longitude]
  end
end
