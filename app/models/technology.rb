class Technology < ActiveRecord::Base
  validates :posted, :name, :city, :state, presence: true
  validates :name, :uniqueness => { :scope => :posted }
  validates :state, length: { minimum: 1 }

end
