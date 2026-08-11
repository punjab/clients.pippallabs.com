class CreateContactsLeadsAndNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :notification_email, :string

    create_table :contacts do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.boolean :email_consent, null: false, default: false
      t.string :email_consent_source
      t.datetime :email_consent_at
      t.boolean :sms_consent, null: false, default: false
      t.string :sms_consent_source
      t.datetime :sms_consent_at
      t.timestamps
    end
    add_index :contacts, %i[tenant_id email], unique: true, where: "email IS NOT NULL"
    add_index :contacts, %i[tenant_id phone], unique: true, where: "phone IS NOT NULL"

    create_table :leads do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :website, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.references :owner, foreign_key: { to_table: :users }
      t.string :idempotency_key, null: false
      t.string :lead_type, null: false
      t.integer :status, null: false, default: 0
      t.datetime :occurred_at, null: false
      t.datetime :follow_up_at
      t.datetime :closed_at
      t.text :message
      t.string :source, null: false, default: "unknown"
      t.text :page_url, null: false, default: "unknown"
      t.string :utm_source, null: false, default: "unknown"
      t.string :utm_medium, null: false, default: "unknown"
      t.string :utm_campaign, null: false, default: "unknown"
      t.decimal :estimated_value, precision: 12, scale: 2
      t.decimal :actual_value, precision: 12, scale: 2
      t.string :lost_reason
      t.string :request_id, null: false
      t.timestamps
    end
    add_index :leads, %i[tenant_id idempotency_key], unique: true
    add_index :leads, %i[tenant_id status created_at]
    add_index :leads, %i[tenant_id location_id created_at]
    add_index :leads, %i[tenant_id owner_id created_at]
    add_index :leads, %i[tenant_id follow_up_at]

    create_table :lead_histories do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :lead, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.string :change_type, null: false
      t.string :from_status
      t.string :to_status
      t.text :note
      t.jsonb :changeset, null: false, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :lead_histories, %i[tenant_id lead_id occurred_at]

    create_table :notifications do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :lead, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.string :kind, null: false
      t.string :recipient
      t.integer :status, null: false, default: 0
      t.integer :attempts, null: false, default: 0
      t.datetime :last_attempted_at
      t.string :provider_message_id
      t.text :last_error
      t.timestamps
    end
    add_index :notifications, %i[lead_id kind], unique: true
    add_index :notifications, %i[tenant_id status created_at]
  end
end
