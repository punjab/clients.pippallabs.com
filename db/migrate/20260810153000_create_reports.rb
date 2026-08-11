class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.integer :version, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.jsonb :metrics, null: false, default: {}
      t.datetime :generated_at
      t.text :generation_error
      t.timestamps
    end
    add_index :reports, %i[tenant_id location_id period_start period_end version],
      unique: true, name: "index_reports_on_scope_period_version", nulls_not_distinct: true
  end
end
