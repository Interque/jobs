module ListingsHelper
  def remote_ip
    if request.remote_ip == '127.0.0.1'
      '104.219.179.22'
    else
      request.remote_ip
    end
  end

  def current_state
    if current_user && current_user.state.present?
      state = current_user.state
    else
      geocoder = Geocoder.search(remote_ip)
      state = geocoder[0].data['region_code']
      state
    end
  end
end
