class Session < ApplicationRecord
  belongs_to :user
  belongs_to :membership, optional: true
end
