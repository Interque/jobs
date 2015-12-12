class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def remote_ip
    if request.remote_ip == '127.0.0.1'
      '104.219.179.22'
    else
      request.remote_ip
    end
  end

end
