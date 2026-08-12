class WorkspaceFeature < ApplicationRecord
  KEYS = %w[recruiting].freeze

  belongs_to :tenant

  validates :key, inclusion: { in: KEYS }, uniqueness: { scope: :tenant_id }
end
