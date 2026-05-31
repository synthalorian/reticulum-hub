class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :node, null: false, foreign_key: true
      t.string :service_type
      t.string :name
      t.string :description
      t.integer :port
      t.json :metadata

      t.timestamps
    end
  end
end
