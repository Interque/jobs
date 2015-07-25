class TechnologiesController < ApplicationController
  before_action :set_technology, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @technologies = Technology.all
    respond_with(@technologies)
  end

  def show
    respond_with(@technology)
  end

  def new
    @technology = Technology.new
    respond_with(@technology)
  end

  def edit
  end

  def create
    @technology = Technology.new(technology_params)
    @technology.save
    respond_with(@technology)
  end

  def update
    @technology.update(technology_params)
    respond_with(@technology)
  end

  def destroy
    @technology.destroy
    respond_with(@technology)
  end

  private
    def set_technology
      @technology = Technology.find(params[:id])
    end

    def technology_params
      params.require(:technology).permit(:tech, :posted, :city, :state)
    end
end
