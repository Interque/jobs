class Technology < ActiveRecord::Base
  validates :posted, uniqueness: true
  validates :name, presence: true
end
