require 'httparty'

task :get_jobs do
  response = HTTParty.get('https://jobs.github.com/positions.json?description=ruby')

  response.each do |job|
    if job.nil?
      next
    else
      puts job['title']
      Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :city => job['location'], :email => job['how_to_apply'], :salary => 1, :user_id => 1)
    end
  end
end