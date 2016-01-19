class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :set_utm_cookie

  def remote_ip
    if request.remote_ip == '127.0.0.1'
      '104.219.179.22'
    else
      request.remote_ip
    end
  end

  def set_utm_cookie
    if current_user.blank? && cookies[:interque_utm_tags].blank?
      interque_source_url = request.base_url + request.original_fullpath
      ip = remote_ip
      utm_stuff = {utm_source: params[:utm_source], utm_campaign: params[:utm_campaign], utm_medium: params[:utm_medium], 
          utm_content: params[:utm_content], utm_term: params[:utm_term], url: interque_source_url, ip_address: remote_ip}.to_json

      cookies[:interque_utm_tags] = {
        value: utm_stuff,
        expires: 1.year.from_now
      }
      # on registration you can create a new entry in UserAttribution (doesn't exist yet)
      # need to do something like this http://stackoverflow.com/questions/5212350/making-changes-to-the-devise-user-controller-in-rails 
    end
  end

end
