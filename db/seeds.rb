# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'httparty'

response = HTTParty.get('https://jobs.github.com/positions.json?description=ruby')

response.each do |job|
  if job.nil?
    next
  elsif job['created_at'] > (Time.now - 5.days)
    Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :city => job['location'], :email => job['how_to_apply'], :salary => 1, :user_id => 1)
  else 
    puts "no new jobs"
  end
end
