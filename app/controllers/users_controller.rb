require 'digest/md5'
require 'rotp'

class UsersController < ApplicationController
  def register
    username = params[:username]
    password = params[:password]
    return error_response('Passwords do not match') unless password == params[:cpassword]

    hashed_password = Digest::MD5.hexdigest(password).upcase
    real_name = params[:realName] || username
    blab_name = params[:blabName] || username
    created_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    totp_secret = ROTP::Base32.random

    # INTENTIONAL SQL INJECTION
    sql = "INSERT INTO users (username, password, password_hint, created_at, real_name, blab_name, totp_secret) VALUES ('#{username}', '#{hashed_password}', '#{username}', '#{created_at}', '#{real_name}', '#{blab_name}', '#{totp_secret}')"
    db_connection.execute(sql)
    success_response('User registered successfully')
  rescue => e
    error_response(e.message, status: 500)
  end

  def login
    username = params[:username]
    hashed_password = Digest::MD5.hexdigest(params[:password]).upcase

    # INTENTIONAL SQL INJECTION
    sql = "SELECT * FROM users WHERE username='#{username}' AND password='#{hashed_password}'"
    result = db_connection.execute(sql).first

    if result
      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      db_connection.execute("UPDATE users SET last_login='#{timestamp}' WHERE username='#{username}'")
      success_response({token: "#{username}_#{hashed_password}"})
    else
      error_response('Invalid credentials', status: 403)
    end
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_users
    results = db_connection.execute("SELECT username, real_name, blab_name, created_at FROM users").to_a
    users = results.map { |row| {username: row[0], real_name: row[1], blab_name: row[2], created_at: row[3]} }
    success_response(users)
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_user
    username = current_user
    sql = "SELECT username, real_name, blab_name, created_at FROM users WHERE username='#{username}'"
    result = db_connection.execute(sql).first
    result ? success_response({username: result[0], real_name: result[1], blab_name: result[2], created_at: result[3]}) : error_response('User not found', status: 404)
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_blabbers
    username = current_user
    sort_param = params[:sort] || 'u.created_at'

    # INTENTIONAL SQL INJECTION in sort
    sql = "SELECT u.username, u.blab_name, u.created_at, COUNT(DISTINCT l1.listener) as listening, COUNT(DISTINCT l2.listener) as listeners FROM users u LEFT JOIN listeners l1 ON l1.blabber = u.username LEFT JOIN listeners l2 ON l2.blabber = u.username AND l2.listener = '#{username}' GROUP BY u.username ORDER BY #{sort_param}"
    results = db_connection.execute(sql).to_a
    blabbers = results.map { |row| {username: row[0], blab_name: row[1], created_at: row[2], listening: row[3], listeners: row[4]} }
    success_response(blabbers)
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_profile_info
    username = current_user
    user_result = db_connection.execute("SELECT username, real_name, blab_name, totp_secret FROM users WHERE username='#{username}'").first
    hecklers = db_connection.execute("SELECT u.username, u.blab_name, u.created_at FROM users u INNER JOIN listeners l ON l.listener = u.username WHERE l.blabber='#{username}'").to_a.map { |row| {username: row[0], blab_name: row[1], created_at: row[2]} }
    events = db_connection.execute("SELECT event FROM users_history WHERE blabber=\"#{username}\"").to_a.map { |row| row[0] }

    success_response({username: user_result[0], realName: user_result[1], blabName: user_result[2], totpSecret: user_result[3], hecklers: hecklers, events: events})
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_events
    username = current_user
    events = db_connection.execute("SELECT event FROM users_history WHERE blabber='#{username}'").to_a.map { |row| row[0] }
    success_response(events)
  rescue => e
    error_response(e.message, status: 500)
  end

  def update_profile
    current = current_user
    new_username = params[:username]
    blab_name = params[:blabName]
    real_name = params[:realName]

    # INTENTIONAL SQL INJECTION
    sql = "UPDATE users SET username='#{new_username}', blab_name='#{blab_name}', real_name='#{real_name}' WHERE username='#{current}'"
    db_connection.execute(sql)
    success_response('Profile updated')
  rescue => e
    error_response(e.message, status: 500)
  end

  def listen
    listener = current_user
    blabber = params[:blabberUsername]
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    # INTENTIONAL SQL INJECTION
    db_connection.execute("INSERT INTO listeners (blabber, listener, status) VALUES ('#{blabber}', '#{listener}', 'Active')")
    db_connection.execute("INSERT INTO users_history (blabber, event, timestamp) VALUES ('#{listener}', '#{listener} started listening to #{blabber}', '#{timestamp}')")
    success_response('Now listening')
  rescue => e
    error_response(e.message, status: 500)
  end

  def ignore
    listener = current_user
    blabber = params[:blabberUsername]
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    # INTENTIONAL SQL INJECTION
    db_connection.execute("DELETE FROM listeners WHERE blabber='#{blabber}' AND listener='#{listener}'")
    db_connection.execute("INSERT INTO users_history (blabber, event, timestamp) VALUES ('#{listener}', '#{listener} stopped listening to #{blabber}', '#{timestamp}')")
    success_response('Stopped listening')
  rescue => e
    error_response(e.message, status: 500)
  end

  def reset
    load Rails.root.join('db', 'seeds.rb')
    success_response('Database reset')
  rescue => e
    error_response(e.message, status: 500)
  end
end
