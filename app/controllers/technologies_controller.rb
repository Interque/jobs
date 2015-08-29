class TechnologiesController < ApplicationController
  def index
    # @technologies = Technology.all.sort { |x, y| Technology.where(:name => y.name).count <=> Technology.where(:name => x.name).count }
    # @technologies = @technologies.select { |t| Technology.where(:name => t.name).count > 5 }
  end
end
