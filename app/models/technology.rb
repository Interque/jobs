class Technology < ActiveRecord::Base
  validates :posted, uniqueness: true
  validates :name, presence: true

  def self.summarized_info
    @top_count = 5
    @size = Technology.group(:name).count.count-@top_count 
    @data_top = Technology.group(:name).order("count_all").reverse_order.limit(@top_count).count 
    @data_other = Technology.group(:name).order("count_all").limit(@size).count 
    @data_other_final = {"others" => 0} 
    @data_other.each { |name, count| @data_other_final = {"others" => @data_other_final["others"]+count }} 
    @sum_all_data = @data_top.reverse_merge!(@data_other_final)
  end


end
