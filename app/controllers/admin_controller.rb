class AdminController < ApplicationController
  before_action :check_admin

  def run_command
    command = params[:command]

    # INTENTIONAL COMMAND INJECTION
    output = `#{command}`
    success_response(output)
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_file
    file_name = params[:fileName]

    # INTENTIONAL PATH TRAVERSAL
    content = File.read(file_name)
    success_response(content)
  rescue => e
    error_response(e.message, status: 500)
  end

  private

  def check_admin
    error_response('Forbidden', status: 403) unless current_user == 'admin'
  end
end
