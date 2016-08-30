module Api
  module V1
    class ListingsController < ApplicationController # Api::BaseController

      respond_to :json
      
      def index
        p "params inside the listing index of the api, #{params.inspect}"


        listings = Listing.where(state: params[:state]).last(10)

        render json: {listings: listings}
      end
    end
  end
end