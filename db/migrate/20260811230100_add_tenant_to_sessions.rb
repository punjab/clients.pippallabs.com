class AddTenantToSessions < ActiveRecord::Migration[8.1]
  def change
    add_reference :sessions, :tenant, null: true, foreign_key: true
  end
end
