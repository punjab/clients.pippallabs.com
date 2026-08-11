class CreateSecureWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :time_zone, null: false, default: "America/Vancouver"
      t.string :default_location_key
      t.timestamps
    end
    add_index :tenants, :slug, unique: true

    create_table :users do |t|
      t.string :name, null: false
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :users, "lower(email_address)", unique: true, name: "index_users_on_lower_email"

    create_table :locations do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :key, null: false
      t.string :alert_email
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :locations, %i[tenant_id key], unique: true

    create_table :memberships do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.integer :role, null: false, default: 3
      t.timestamps
    end
    add_index :memberships, %i[tenant_id user_id], unique: true

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :membership, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end
  end
end
