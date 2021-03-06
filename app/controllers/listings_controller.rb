class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :require_login, only: [:create, :update, :edit, :destroy]
  before_action :creator, only: [:update, :edit]
  before_filter :wyncode_authenticate, only: [:wyncode]
  # after_save :update_categories

  # GET /listings
  # GET /listings.json
  def index
    @listing = Listing.new

    if params[:tag] # if searching by tag
      @listings = Listing.where(wyncode_only: false).tagged_with(params[:tag].downcase).page(params[:page]).per_page(20).order(:created_at => :desc) #.per_page(12).order(:created_at => :desc)      
    elsif params[:all] 
      @listings = active_listings
    elsif params[:us]
      @listings = Listing.where(:country => "US").paginate(:page => params[:page], :per_page => 20).order(:created_at => :desc)
    elsif params[:international]
      @listings = Listing.where(:country => nil, wyncode_only: false).paginate(:page => params[:page], :per_page => 20).order(:created_at => :desc)
    elsif current_user && params[:search].blank? && current_user.state.present?
      @listings = Listing.where(active: true, state: current_user.state, wyncode_only: false).paginate(:page => params[:page], :per_page => 20).order("created_at DESC")
    elsif (params[:search].blank? && remote_ip) || (params[:my_state] && remote_ip)
      # @geocoder_current_state = geocoder_current_state
      unless Listing.where(:active => true, :state => geocoder_current_state).count == 0
        @listings = Listing.where(:active => true, :state => geocoder_current_state, wyncode_only: false).paginate(:page => params[:page], :per_page => 20).order(:created_at => :desc)
      else
        @listings = active_listings
      end
    elsif params[:search]
      @listings = Listing.search(params[:search])
    else
      @listings = active_listings
    end

    # trying to make fewer geocoder api calls
    if current_user && current_user.state.nil?
      unless geocoder_current_state.nil?
        current_user.state = geocoder_current_state
        current_user.save
      end
    end
  end

  def active_listings
    Listing.where(:active => true, wyncode_only: false).page(params[:page]).per_page(20).order(:created_at => :desc)
  end

  def geocoder_current_state
    begin
      geocoder = Geocoder.search(remote_ip)
      unless geocoder[0].nil?
        state = geocoder[0].data['region_code']
      else
        state = 'FL'
      end
    rescue => e
      puts "an error occurred: #{e}"
      state = 'FL'
    end
    state
  end

  def paramless

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
        # post_to_slack(@listing.id)
        # update_categories
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

  def post_to_slack(app_id)
    job = Listing.find(app_id)

    if job.state == 'FL'
      # base_url = "<http://localhost:3000/listings/#{app_id}>"
      base_url = "<http://jobs.interque.co/listings/#{app_id}>"
      payload = { text: "New job opportunity with #{job.organization} in #{job.city}, #{job.state}\n #{base_url}", username: "interque" }
      p payload
      p "#{'!'*20}"
      p payload.to_json
      response = HTTParty.post('https://hooks.slack.com/services/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', body: payload.to_json )

      p response.inspect
    end
  end

  def tags
    # tags = ActsAsTaggableOn::Tag.all
    tags = Listing.all_tag_counts.by_tag_name(params[:q]).token_input_tags

    respond_to do |format|
      format.json { render json: tags }
    end
  end

  def wyncode
    @listings = Listing.where(wyncode_only: true)
  end

  def wyncode_authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == ENV["WYNCODE_USERNAME"] && password == ENV["WYNCODE_PASSWORD"]
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:title, :description, :organization, :email, :salary, :city, :state, :user_id, :location, :source, :posted, :contact, :category, :tag_list, :wyncode_only)
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
