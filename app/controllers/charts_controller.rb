class ChartsController < ApplicationController
  def tech_name
    render json: Technology.group(:name).count(:name)
  end
end
