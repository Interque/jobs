require 'httparty'

task :get_jobs => :environment do
  response = HTTParty.get('https://jobs.github.com/positions.json?description=ruby')

  response.each do |job|
    if job.nil?
      puts "job was nil"
      next
    elsif job['created_at'] > (Time.now - 1.days)
    # elsif Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :city => job['location'], :email => job['how_to_apply'], :salary => 1, :user_id => 1, :posted => job['created_at'], :source => 'github').valid?
      if job['location'].include?(',')
        p "job['location']: #{job['location'].split(",").count}"
        if job['location'].split(",").count > 2
          city = job['location'].split(",")[0]
          state = job['location'].split(",")[1]
          country = job['location'].split(",")[2]
          puts "city: #{city}, state: #{state}, country: #{country}"
        elsif job['location'].split(",").count > 1
          city = job['location'].split(",")[0]
          state = job['location'].split(",")[1]
          puts "city: #{city}, state: #{state}"
        else
          city = job['location'].split(",")[0]
          state = ""
          puts "city: #{city}"
        end
      elsif job['location'].include?('/')
        puts "it has a slash. do something else"
        if job['location'].split("/").count > 1
          city = job['location'].split("/")[0]
          state = job['location'].split("/")[1]
          puts "city: #{city}, state: #{state}"
        else 
          city = job['location']
          puts "city: #{city}"
        end
      else
        city = job['location']
        state = ""
        puts "no comma or slash"
        puts "city: #{city}"
      end

      p "validated: #{Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :location => job['location'], :city => city, :state => state, :email => job['how_to_apply'], :salary => 1, :user_id => 1, :posted => job['created_at'], :source => 'github').valid?}"
      Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :location => job['location'], :city => city, :state => state, :contact => job['how_to_apply'], :salary => 1, :user_id => 1, :posted => job['created_at'], :source => 'github')
      puts "created a job"
    else 
      puts "no new jobs"
    end
  end
end

task :clean do
end