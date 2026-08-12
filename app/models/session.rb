class Session < ApplicationRecord
  belongs_to :user
  belongs_to :membership, optional: true
  belongs_to :tenant, optional: true

  # Non-super users derive tenant strictly from their membership so revoking a
  # membership fails closed; the explicit tenant column only steers super admins.
  def tenant
    return super || membership&.tenant if user.super_admin?

    membership&.tenant
  end
end
