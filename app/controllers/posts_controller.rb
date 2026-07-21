class PostsController < ApplicationController
  def get_blabs_for_me
    username = current_user
    sql = "SELECT b.blabid, b.blabber, b.content, b.timestamp FROM blabs b INNER JOIN listeners l ON l.blabber = b.blabber WHERE l.listener = '#{username}' ORDER BY b.timestamp DESC"
    results = db_connection.execute(sql).to_a
    blabs = results.map { |row| {blabid: row[0], blabber: row[1], content: row[2], timestamp: row[3]} }
    success_response(blabs)
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_blabs_by_me
    username = current_user
    sql = "SELECT blabid, blabber, content, timestamp FROM blabs WHERE blabber='#{username}' ORDER BY timestamp DESC"
    results = db_connection.execute(sql).to_a
    blabs = results.map { |row| {blabid: row[0], blabber: row[1], content: row[2], timestamp: row[3]} }
    success_response(blabs)
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_all_blabs
    results = db_connection.execute("SELECT blabid, blabber, content, timestamp FROM blabs ORDER BY timestamp DESC").to_a
    blabs = results.map { |row| {blabid: row[0], blabber: row[1], content: row[2], timestamp: row[3]} }
    success_response(blabs)
  rescue => e
    error_response(e.message, status: 500)
  end

  def add_blab
    blabber = current_user
    content = params[:blab]
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    # INTENTIONAL SQL INJECTION
    sql = "INSERT INTO blabs (blabber, content, timestamp) VALUES ('#{blabber}', '#{content}', '#{timestamp}')"
    db_connection.execute(sql)
    success_response('Blab added')
  rescue => e
    error_response(e.message, status: 500)
  end

  def get_blab_comments
    blab_id = params[:blabId]

    # INTENTIONAL SQL INJECTION - using double quotes like JS version
    sql = "SELECT commentid, blabid, blabber, content, timestamp FROM comments WHERE blabid=\"#{blab_id}\""
    results = db_connection.execute(sql).to_a
    comments = results.map { |row| {commentid: row[0], blabid: row[1], blabber: row[2], content: row[3], timestamp: row[4]} }
    success_response(comments)
  rescue => e
    error_response(e.message, status: 500)
  end

  def add_blab_comment
    blabber = current_user
    blab_id = params[:blabId]
    content = params[:comment]
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

    # INTENTIONAL SQL INJECTION
    sql = "INSERT INTO comments (blabid, blabber, content, timestamp) VALUES (#{blab_id}, '#{blabber}', '#{content}', '#{timestamp}')"
    db_connection.execute(sql)
    success_response('Comment added')
  rescue => e
    error_response(e.message, status: 500)
  end

  def delete_blab
    username = current_user
    blab_id = params[:blabId]
    return error_response('Forbidden', status: 403) unless username == 'admin'

    # INTENTIONAL SQL INJECTION
    sql = "DELETE FROM blabs WHERE blabid='#{blab_id}'"
    db_connection.execute(sql)
    success_response('Blab deleted')
  rescue => e
    error_response(e.message, status: 500)
  end
end
