class Listing < ActiveRecord::Base
	belongs_to :user

	validates :salary, inclusion: (1..8)
	RANGE_OPTIONS=[['not specified', 1], ['less than 50k', 2], ['50k-75k', 3], ['76k-100k', 4], ['101k-125k', 5], ['126k-150k', 6], ['151k-200k', 7], ['more than 200k', 8]]
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
end
