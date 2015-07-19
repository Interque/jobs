class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :require_login, only: [:create, :update, :edit, :destroy]
  before_action :creator, only: [:update, :edit]

  # GET /listings
  # GET /listings.json
  def index
    # @listings = Listing.all
    if params[:search].blank?
      @listings = Listing.page(params[:page]).per_page(15).order(:created_at => :desc)
    else
      @listings = Listing.search(params[:search])
    end
    @listing = Listing.new
  end

  # GET /listings/1
  # GET /listings/1.json
  def show
  end

  # GET /listings/new
  def new
    @listing = Listing.new
    @user = @listing.user.new
  end

  # GET /listings/1/edit
  def edit
    unless @listing.user_id == current_user.id || current_user.admin
      redirect_to root_url
    end
  end

  # POST /listings
  # POST /listings.json
  def create
    @listing = Listing.new(listing_params)


    respond_to do |format|
      if @listing.save
        format.html { redirect_to listing_path(@listing), notice: 'Listing was successfully created.' }
        format.json { render :show, status: :created, location: @listing }
      else
        format.html { render :new }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /listings/1
  # PATCH/PUT /listings/1.json
  def update
    respond_to do |format|
      if @listing.update(listing_params)
        format.html { redirect_to @listing, notice: 'Listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @listing }
      else
        format.html { render :edit }
        format.json { render json: @listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /listings/1
  # DELETE /listings/1.json
  def destroy
    unless @listing.user_id == current_user.id
      redirect_to root_url
    end

    @listing.destroy
    respond_to do |format|
      format.html { redirect_to listings_url, notice: 'Listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:title, :description, :organization, :email, :salary, :city, :state, :user_id)
    end

    def require_login
      unless current_user
        redirect_to root_url, { :notice => "Please login to continue." }
      end
    end

    def creator
      unless @listing.user_id == current_user.id || current_user.admin
        redirect_to root_url
      end
    end
end
