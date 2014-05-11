class API::Devices::SessionsController < API::ApplicationController
  before_filter :authenticate_from_token!

  def create
    device = Device.find_by_id(credentials[:id])
    pin = API::Devices::Pin.find_by_pin(credentials[:pin])

    if device && pin && user_signed_in?
      pin.destroy!

      status = :ok
    else
      status = :bad_request
    end

    head status
  end

private

  def credentials
    params.permit(:id, :pin)
  end

end # API::Devices::SessionsController
