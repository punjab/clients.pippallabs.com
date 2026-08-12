class CreateWorkspaceFeatures < ActiveRecord::Migration[8.1]
  def change
    create_table :workspace_features do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :key, null: false
      t.boolean :enabled, null: false, default: false
      t.timestamps
    end

    add_index :workspace_features, %i[tenant_id key], unique: true
  end
end
