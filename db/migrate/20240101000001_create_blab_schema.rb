class CreateBlabSchema < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE TABLE users (
        username varchar(100) NOT NULL PRIMARY KEY,
        password varchar(100) DEFAULT NULL,
        password_hint varchar(100) DEFAULT NULL,
        created_at datetime DEFAULT NULL,
        last_login datetime DEFAULT NULL,
        real_name varchar(100) DEFAULT NULL,
        blab_name varchar(100) DEFAULT NULL,
        totp_secret varchar(100) DEFAULT NULL
      );
    SQL

    execute <<-SQL
      CREATE TABLE blabs (
        blabid INTEGER PRIMARY KEY AUTOINCREMENT,
        blabber varchar(100) NOT NULL,
        content varchar(250) DEFAULT NULL,
        timestamp datetime DEFAULT NULL
      );
    SQL

    execute <<-SQL
      CREATE TABLE comments (
        commentid INTEGER PRIMARY KEY AUTOINCREMENT,
        blabid integer NOT NULL,
        blabber varchar(100) NOT NULL,
        content varchar(250) DEFAULT NULL,
        timestamp datetime DEFAULT NULL
      );
    SQL

    execute <<-SQL
      CREATE TABLE listeners (
        blabber varchar(100) NOT NULL,
        listener varchar(100) NOT NULL,
        status varchar(20) DEFAULT NULL
      );
    SQL

    execute <<-SQL
      CREATE TABLE users_history (
        eventid INTEGER PRIMARY KEY AUTOINCREMENT,
        blabber varchar(100) NOT NULL,
        event varchar(250) DEFAULT NULL,
        timestamp datetime DEFAULT NULL
      );
    SQL
  end

  def down
    drop_table :users_history
    drop_table :listeners
    drop_table :comments
    drop_table :blabs
    drop_table :users
  end
end
