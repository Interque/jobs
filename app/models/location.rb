class Location < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :state, scope: [:user_id ]
end
