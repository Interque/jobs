require 'httparty'
require 'feedjira'
require 'geocoder'

task :set_country => :environment do
  Listing.find_each do |listing|
    begin
      if listing.country.blank?
        states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA',
        'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI',
        'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND',
        'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT',
        'VA', 'WA', 'WV', 'WI', 'WY']

        p "listing.state: #{listing.state}"

        unless listing.state.blank?
          if states.include?(listing.state.strip)
            listing.country = 'US'
            listing.save
            p "set US as country"
          else
            puts "non-US listing.state: #{listing.state}"
          end
        end
      end
    rescue => e
      puts "an error occurred: #{e}"
    end
  end
end


task :find_countries => :environment do
  Listing.find_each do |listing|
    begin
      city_state = ""
      city = listing.city
      state = listing.state
      city_state << city + ", "
      city_state << state
      p "city: #{city}"
      p "state: #{state}"
      p "city_state: #{city_state}"
      geo = Geocoder.search(city_state)
      country_long = geo[0].data["address_components"][3]["long_name"]
      country_short = geo[0].data["address_components"][3]["short_name"]
      listing.country = country_short
      listing.save
    rescue => e
      puts "an error occurred: #{e}"
    end
  end
end

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
          city_state = ""
          city = job['location'].split(",")[0]
          state = job['location'].split(",")[1]
          city_state << city + ","
          city_state << state
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
      
      # if country.nil?
      #   unless state.blank?
      #     states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA',
      #       'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI',
      #       'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND',
      #       'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT',
      #       'VA', 'WA', 'WV', 'WI', 'WY']

      #     if states.include?(state)
      #       country = 'US'
      #     end
      #   else
      #     geo = Geocoder.search(city_state)
      #     country = geo[0].data["address_components"][3]["short_name"]
      #   end
      # end
      Listing.create(:title => job['title'], :description => job['description'], :organization => job['company'], :location => job['location'], :city => city, :state => state, :contact => job['how_to_apply'], :salary => 1, :user_id => 1, :posted => job['created_at'], :source => 'github', :web_url => job['company_url'], :country => country)
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
    if entry.published > (Time.now - 1.days)
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

        
        # unless state.blank?
        #   states = ['AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA',
        #     'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI',
        #     'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND',
        #     'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT',
        #     'VA', 'WA', 'WV', 'WI', 'WY']

        #   if states.include?(state)
        #     country = 'US'
        #   end
        # else
        #   geo = Geocoder.search(location)
        #   country = geo[0].data["address_components"][3]["short_name"]
        # end

      end
      l = Listing.create(:title => position, :description => entry.summary, 
                         :organization => organization, :location => location, 
                         :city => city, :state => state, 
                         :contact => entry.url, :salary => 1, 
                         :user_id => 1, :posted => entry.published, 
                         :source => 'stackoverflow', 
                         :category => entry.categories.join(', '))
      l.tag_list.add(entry.categories.join(', '), parse: true)
      l.save
    else
      puts "job is too old"
    end
  end
end

task :create_tech => :environment do
  url = "http://careers.stackoverflow.com/jobs/feed"
  feed = Feedjira::Feed.fetch_and_parse(url)

  feed.entries.each do |entry|
    if entry.published > (Time.now - 1.days)

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

      ignore_arr = ["mobile", "agile", "mongodb", "nosql", "postgresql", "sysadmin", "git", "mysql"]

      entry.categories.each do |cat|
        puts "cat: #{cat}"
        if cat.include?('ruby') # for ruby
          name = 'ruby-on-rails'
        elsif cat.include?('html') # for html5
          name = 'html'
        elsif cat.include?('css') # for css3
          name = 'css'
        elsif cat.include?('angular')
          name = 'angularjs'
        elsif cat.include?('backbone')
          name = 'backbone.js'
        else
          name = cat
        end

        unless ignore_arr.include?(name)
          Technology.create(:name => name, :city => city, :state => state, :posted => entry.published)
        end
      end
    end
  end
  # puts "num entries: #{feed.entries.count}"
end

task :inspect_stack do
  url = "http://careers.stackoverflow.com/jobs/feed"
  feed = Feedjira::Feed.fetch_and_parse(url)

  # p feed.entries.inspect

  feed.entries.each do |entry|
    entry.categories.each do |name|
      if name.include?('node')
        puts name
      end
    end
  end

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
  # should only have had to run once on first deploy
  # then run create_tech
  # then clean_count
  puts "in fix_overlap"
  Technology.find_each do |t|
    if t.name == 'ruby' || t.name == 'html5' || t.name == 'css3'
      t.destroy
    else
      puts t.name
    end
  end
end

task :check_names => :environment do
  # was just checking for other forms
  Technology.find_each do |t|
    if t.name.include?('node')
      puts t.name
    end
  end
end

task :clean_count => :environment do
  # clean after running create_tech to get rid tech that occurs infrequently
  ignore_arr = ["mobile", "agile", "mongodb", "nosql", "postgresql", "sysadmin", "git"]
  Technology.all.each do |t|
    if Technology.where(:name => t.name).count <= 40
      t.destroy
    elsif ignore_arr.include?(t.name)
      t.destroy
    else
      puts "#{t.name} made the cut"
    end
  end

  puts Technology.count
end

task :test_geocoder => :environment do
  g = Geocoder.search("St. Louis, MO")
  g.each do |location|
    location.data["address_components"].each do |c|
      if c["types"].include?("locality")
        p c["long_name"]
        p c["short_name"]
      end

      if c["types"].include?("administrative_area_level_1")
        p c["long_name"]
        p c["short_name"]
      end
    end
  end
end

task :test_description => :environment do
  response = HTTParty.get('https://jobs.github.com/positions.json')

  response.each do |job|
    puts job['search']
  end
end

task :location_by_ip => :environment do
  g = Geocoder.search(request.remote_ip)
end

task :deactivate_old_jobs => :environment do
  Listing.find_each do |l|
    begin
      # if l.created_at is more than 12 months old
      if l.created_at <= Time.now - 11.months
        # don't really want to delete data...better to deactivate it, right?
        p "l: #{l}"
        p "l.email: #{l.email}"
        p "l.organization: #{l.organization}"
        p "l.created_at: #{l.created_at}"
        l.active = false
        l.save
      end
      # might not need this now...
      # but if job is older than x
      # delete it or hide it
    rescue => e
      puts "there was an error: #{e}"
    end
  end
end
