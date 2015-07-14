require 'httparty'

task :get_jobs => :environment do
  response = HTTParty.get('https://jobs.github.com/positions.json?description=ruby')

  response.each do |job|
    if job.nil?
      puts "job was nil"
      next
    elsif job['created_at'] > (Time.now - 5.days)
      Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :city => job['location'], :email => job['how_to_apply'], :salary => 1, :user_id => 1)
      puts "created a job"
    else 
      puts "no new jobs"
    end
  end
end

task :clean do
end