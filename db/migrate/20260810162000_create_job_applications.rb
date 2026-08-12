class CreateJobApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :job_applicants do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.timestamps
    end
    add_index :job_applicants, %i[tenant_id email], unique: true

    create_table :job_applications do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :website, null: false, foreign_key: true
      t.references :job_posting, null: false, foreign_key: true
      t.references :job_applicant, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.string :idempotency_key, null: false
      t.integer :status, null: false, default: 0
      t.datetime :occurred_at, null: false
      t.text :availability
      t.text :experience
      t.text :motivation
      t.string :source, null: false, default: "unknown"
      t.text :page_url, null: false, default: "unknown"
      t.string :privacy_notice_version, null: false
      t.boolean :future_opportunities_consent, null: false, default: false
      t.string :request_id, null: false
      t.timestamps
    end
    add_index :job_applications, %i[tenant_id idempotency_key], unique: true
    add_index :job_applications, %i[tenant_id status created_at]
    add_index :job_applications, %i[tenant_id location_id created_at]

    create_table :job_application_histories do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :job_application, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.string :change_type, null: false
      t.string :from_status
      t.string :to_status
      t.text :note
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :job_application_histories, %i[tenant_id job_application_id occurred_at], name: "index_job_application_histories_on_tenant_application_time"
  end
end
