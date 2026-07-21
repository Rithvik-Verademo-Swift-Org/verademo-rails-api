class VulnerableAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    # Skip auth for unprotected routes
    unprotected = ['/', '/users/register', '/users/login', '/users/reset', '/posts/getAllBlabs']
    return @app.call(env) if unprotected.include?(request.path)

    auth_header = env['HTTP_AUTHORIZATION']
    unless auth_header
      return [401, {'Content-Type' => 'application/json'},
              [{success: 0, data: 'Unauthenticated'}.to_json]]
    end

    # Parse token format: "Bearer: username_password"
    token_parts = auth_header.split(': ')
    return forbidden_response('Invalid token format') if token_parts.length < 2

    creds = token_parts[1].split('_')
    return forbidden_response('Invalid credentials format') if creds.length < 2

    # INTENTIONAL SQL INJECTION VULNERABILITY
    sql = "SELECT * FROM users WHERE username='#{creds[0]}' AND password='#{creds[1]}'"

    begin
      result = ActiveRecord::Base.connection.execute(sql).first
      if result
        env['current_user'] = result[0]  # username column
        @app.call(env)
      else
        forbidden_response('Invalid credentials')
      end
    rescue => e
      [500, {'Content-Type' => 'application/json'}, [{success: 0, data: e.message}.to_json]]
    end
  end

  private

  def forbidden_response(message)
    [403, {'Content-Type' => 'application/json'}, [{success: 0, data: message}.to_json]]
  end
end
