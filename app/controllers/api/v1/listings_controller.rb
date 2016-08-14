module Api
  module V1
    class ListingsController < ApplicationController # Api::BaseController

      respond_to :json
      
      def index
        p "inside the listing index of the api"


        listings = Listing.where(state: params[:state]).last(10)

        render json: {listings: listings}
      end
    end
  end
end