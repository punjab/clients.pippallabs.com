class CreateJobPostings < ActiveRecord::Migration[8.1]
  def change
    create_table :job_postings do |t|
      t.references :tenant, null: false, foreign_key: true
      t.references :location, foreign_key: true
      t.string :title, null: false
      t.string :key, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :job_postings, %i[tenant_id key], unique: true
    add_index :job_postings, %i[tenant_id status created_at]
  end
end
