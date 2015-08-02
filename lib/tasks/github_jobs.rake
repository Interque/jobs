require 'httparty'
require 'feedjira'

task :get_jobs => :environment do
  response = HTTParty.get('https://jobs.github.com/positions.json')  

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
      if job['company_url'] 
        p "company_url: #{job['company_url']}"
      end
      p "validated: #{Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :location => job['location'], :city => city, :state => state, :email => job['how_to_apply'], :salary => 1, :user_id => 1, :posted => job['created_at'], :source => 'github').valid?}"
      Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :location => job['location'], :city => city, :state => state, :contact => job['how_to_apply'], :salary => 1, :user_id => 1, :posted => job['created_at'], :source => 'github', :web_url => job['company_url'])
      puts "created a job"
    else 
      puts "no new jobs"
      if job['company_url'] 
        p "company_url: #{job['company_url']}"
      end
    end
  end
end

task :stack_jobs => :environment do
  url = "http://careers.stackoverflow.com/jobs/feed?searchTerm=ruby"
  feed = Feedjira::Feed.fetch_and_parse(url)

  feed.entries.each do |entry|
    if entry.published > (Time.now - 1.days) || entry.title.include?("Miami")
      puts "num entries: #{feed.entries.count}"
      puts "entry title: #{entry.title}"
      title_arr = entry.title.split('(')
      p title_arr
      if title_arr.length > 0
        job_title = title_arr[0]
        if job_title.split(' ').include?("at")
          job_title_arr = job_title.split(/\s(at)/)
          p job_title_arr
          position = job_title_arr[0].rstrip.lstrip
          p "position: #{position}"
          organization = job_title_arr[2].rstrip.lstrip
          p "organization: #{organization}"
        end

        city = title_arr[1].gsub(")", "").split(",")[0]

        puts "job_title: #{job_title}"
        puts "city: #{city}"

        if title_arr[1].gsub(")", "").split(",")[1]
          state = title_arr[1].gsub(")", "").split(",")[1].rstrip.lstrip
          puts "state: #{state}"
          puts ""
          location = city + ", " + state
        else
          state = ""
          location = city
        end
      end
      puts "entry summary: #{entry.summary}"
      puts "entry published: #{entry.published}"
      puts "categories: #{entry.categories}"
      Listing.create(:title => position, :description => entry.summary, :organization => organization, :location => location, :city => city, :state => state, :contact => entry.url, :salary => 1, :user_id => 1, :posted => entry.published, :source => 'stackoverflow', :category => entry.categories.to_s)
    else
      puts "job is too old"
    end
  end
end

task :count_jobs => :environment do
  url = "http://careers.stackoverflow.com/jobs/feed"
  feed = Feedjira::Feed.fetch_and_parse(url)
  
  feed.entries.each do |entry|

    title_arr = entry.title.split('(')
    p title_arr

    if title_arr.length > 0
      job_title = title_arr[0]
      if job_title.split(' ').include?("at")
        job_title_arr = job_title.split(/\s(at)/)
        p job_title_arr
        position = job_title_arr[0].rstrip.lstrip
        organization = job_title_arr[2].rstrip.lstrip
      end

      city = title_arr[1].gsub(")", "").split(",")[0]

      puts "job_title: #{job_title}"
      puts "city: #{city}"

      if title_arr[1].gsub(")", "").split(",")[1]
        state = title_arr[1].gsub(")", "").split(",")[1].rstrip.lstrip
        puts "state: #{state}"
        puts ""
        location = city + ", " + state
      else
        state = ""
        location = city
      end
    end

    entry.categories.each do |cat|
      puts "cat: #{cat}"
      if cat == 'ruby'
        name = 'ruby-on-rails'
      elsif cat == 'html5'
        name = 'html'
      else
        name = cat
      end
      Technology.create(:name => name, :city => city, :state => state, :posted => entry.published)
    end
  end
  puts "num entries: #{feed.entries.count}"
end

task :inspect_stack do
  url = "http://careers.stackoverflow.com/jobs/feed"
  feed = Feedjira::Feed.fetch_and_parse(url)

  p feed.entries.inspect

end

task :how_many => :environment do
  # this is basically the view...but sorted
  total = 0
  technologies = []
  Technology.all.each do |technology|
    puts "technologies.include?(technology): #{technologies.include?(technology)}"
    unless technologies.include?(technology.name)
      technologies << technology.name
      this_num = Technology.where(:name => technology.name).count
      puts "number of #{technology.name} jobs: #{Technology.where(:name => technology.name).count}"
      total += this_num
    end
  end
  puts total
end

task :fix_overlap => :environment do
  puts "in fix_overlap"
  Technology.find_each do |t|
    if t.name == 'ruby' || t.name == 'html5'
      t.destroy
    else
      puts t.name
    end
  end
end

task :clean_count => :environment do
  Technology.all.each do |t|
    if Technology.where(:name => t.name).count <= 5
      t.destroy
    else
      puts "#{t.name} made the cut"
    end
  end

  puts Technology.count
end







