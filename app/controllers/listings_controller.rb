class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :require_login, only: [:create, :update, :edit, :destroy]
  before_action :creator, only: [:update, :edit]
  # after_save :update_categories

  # GET /listings
  # GET /listings.json
  def index
    
    if params[:tag]
      @listings = Listing.tagged_with(params[:tag].downcase) #.per_page(12).order(:created_at => :desc)
      # @listings = Listing.all
    elsif params[:search].blank?
      if remote_ip
        g = Geocoder.search(remote_ip)
        current_state = g[0].data['region_code']
        unless Listing.where(:active => true, :state => current_state).count == 0
          @listings = Listing.where(:active => true, :state => current_state).paginate(:page => params[:page], :per_page => 20)
        else
          @listings = Listing.where(:active => true).page(params[:page]).per_page(20).order(:created_at => :desc)
        end  
      else
        @listings = Listing.where(:active => true).page(params[:page]).per_page(20).order(:created_at => :desc)
      end
    elsif params[:search]
      @listings = Listing.search(params[:search])
    elsif remote_ip
      g = Geocoder.search(remote_ip)
      current_state = g[0].data['region_code']
      @listings = Listing.where(:active => true, :state => current_state).paginate(:page => params[:page], :per_page => 20)
    else
      @listings = Listing.where(:active => true).per_page(20).order(:created_at => :desc)
    end
    @listing = Listing.new

    unless request.remote_ip.blank?
      g = Geocoder.search(remote_ip)
      puts "g: #{g.inspect}"
      puts "g.data['region_code']: #{g[0].data['region_code']}"
      if current_user
        puts "last_sign_in_ip: #{current_user.last_sign_in_ip}"
        location = Location.create(ip: g[0].data['ip'], state: g[0].data['region_code'], city: g[0].data['city'], zip: g[0].data['zip_code'], country: g[0].data['country_name'], user_id: current_user.id)
        puts "location created"
      end
    end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_listing
      @listing = Listing.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def listing_params
      params.require(:listing).permit(:title, :description, :organization, :email, :salary, :city, :state, :user_id, :location, :source, :posted, :contact, :category, :tag_list)
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
