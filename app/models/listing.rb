class Listing < ActiveRecord::Base
	belongs_to :user

	acts_as_taggable

  validates :title, :description, :organization, :city, :state, presence: true
  validates :description, uniqueness: true
  validates_uniqueness_of :title, scope: [:organization, :city]
	validates :salary, inclusion: (1..8)

	RANGE_OPTIONS=[['not specified', 1], ['less than 50k', 2], ['50k-75k', 3], ['76k-100k', 4], ['101k-125k', 5], ['126k-150k', 6], ['151k-200k', 7], ['more than 200k', 8]]

	after_save :post_to_slack
	before_save :update_categories

	def post_to_slack # why is it posting to slack twice?
    unless Rails.env == "development"
  		job = Listing.find(self.id)
      if job.state == 'FL'
        # base_url = "<http://localhost:3000/listings/#{app_id}>"
        base_url = "<http://jobs.interque.co/listings/#{self.id}>"
        payload = { text: "New job opportunity with #{job.organization} in #{job.city}, #{job.state}\n #{base_url}", username: "interque" }
        response = HTTParty.post('https://hooks.slack.com/services/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', body: payload.to_json )
      end
    end
	end

	def update_categories
    if self.tag_list.length > 0
      self.category = self.tag_list.join(', ')
    end
  end

	def convert_range(num)
		if num == 1
			'not specified'
		elsif num == 2
			'less than 50k'
		elsif num == 3
			'50k-75k'
		elsif num == 4
			'76k-100k'
		elsif num == 5
			'101k-125k'
		elsif num == 6
			'126k-150k'
		elsif num == 7
			'151k-200k'
    elsif num == 8
      'more than 200k'
    end
  end

  def self.search(search)
    if search #&& Listing.where(["city LIKE ? OR state LIKE ?", "#{search}", "#{search}"]).count == 0
      if Listing.tagged_with(search.downcase).count > 0
        Listing.tagged_with(search.downcase)
      else
        Listing.where(["city LIKE ? OR state LIKE ?", "#{search}", "#{search}"]).order("updated_at DESC")
      end
    else
      Listing.all
    end
  end

  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

	# def update_categories
	# 	if self.tag_list.length > 0
	# 		self.category << self.tag_list.join(', ')
	# 	end
	# end

  # def conditions
  #   [conditions_clauses.join(' AND '), *conditions_options]
  # end

  # def conditions_clauses
  #   conditions_parts.map { |condition| condition.first }
  # end

  # def conditions_options
  #   conditions_parts.map { |condition| condition[1..-1] }.flatten
  # end

  # def conditions_parts
  #   private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  # end

end
