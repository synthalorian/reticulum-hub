class CreateAlertRules < ActiveRecord::Migration[8.1]
  def change
    create_table :alert_rules do |t|
      t.string :name
      t.string :condition
      t.float :threshold
      t.json :notification_channels
      t.boolean :enabled
      t.json :metadata

      t.timestamps
    end
  end
end
