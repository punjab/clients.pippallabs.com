class CreateWebsitesAndEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :websites do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :fallback_location, foreign_key: { to_table: :locations }
      t.string :name, null: false
      t.string :allowed_domain, null: false
      t.string :tracking_key_digest, null: false
      t.string :tracking_key_hint, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :websites, :tracking_key_digest, unique: true
    add_index :websites, %i[tenant_id allowed_domain], unique: true

    create_table :events do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :website, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.datetime :occurred_at, null: false
      t.datetime :accepted_at, null: false
      t.string :session_id, null: false
      t.string :anonymous_id
      t.text :page_url, null: false
      t.text :landing_page, null: false, default: "unknown"
      t.text :referrer, null: false, default: "unknown"
      t.string :utm_source, null: false, default: "unknown"
      t.string :utm_medium, null: false, default: "unknown"
      t.string :utm_campaign, null: false, default: "unknown"
      t.string :utm_term, null: false, default: "unknown"
      t.string :utm_content, null: false, default: "unknown"
      t.string :device_class, null: false, default: "unknown"
      t.jsonb :metadata, null: false, default: {}
      t.boolean :bot, null: false, default: false
      t.boolean :internal, null: false, default: false
      t.string :request_id, null: false
      t.timestamps
    end
    add_index :events, %i[tenant_id event_id], unique: true
    add_index :events, %i[tenant_id occurred_at]
    add_index :events, %i[tenant_id event_type occurred_at]
    add_index :events, %i[tenant_id session_id occurred_at]
    add_index :events, %i[tenant_id location_id occurred_at]
  end
end
