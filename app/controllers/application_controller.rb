class ApplicationController < ActionController::API
  def current_user
    request.env['current_user']
  end

  def success_response(data)
    render json: {success: 1, data: data}
  end

  def error_response(message, status: 400)
    render json: {success: 0, data: message}, status: status
  end

  def db_connection
    ActiveRecord::Base.connection
  end
end
