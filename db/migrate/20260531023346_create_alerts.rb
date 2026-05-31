class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.references :alert_rule, null: false, foreign_key: true
      t.string :status
      t.string :severity
      t.string :message
      t.json :details
      t.datetime :triggered_at
      t.datetime :acknowledged_at
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
