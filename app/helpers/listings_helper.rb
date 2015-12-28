module ListingsHelper
  def remote_ip
    if request.remote_ip == '127.0.0.1'
      '104.219.179.22'
    else
      request.remote_ip
    end
  end

  def current_state
    begin
      if current_user && current_user.state.present?
        state = current_user.state
      else
        geocoder = Geocoder.search(remote_ip)
        unless geocoder.blank?
          state = geocoder[0].data['region_code'] 
        end
      end
    rescue => e
      p "an error occurred: #{e}"
      state = 'FL'
    end
    state
  end
end
