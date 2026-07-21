# Load demo data from JavaScript version
require 'digest/md5'

puts "Loading demo data..."

# Read SQL file from JavaScript version
sql_file_path = Rails.root.join('..', 'verademo-javascript-api', 'db', '1_blab.sql')

if File.exist?(sql_file_path)
  sql_content = File.read(sql_file_path)

  # Extract INSERT statements and execute them
  # Convert MySQL-specific syntax to SQLite3
  sql_content.scan(/INSERT INTO `(\w+)` VALUES (.+?);/m).each do |table, values|
    # Skip table locks and other MySQL-specific commands
    next if values.nil? || values.empty?

    # Convert MySQL backticks to nothing (SQLite doesn't need them for table names)
    table_name = table.gsub('`', '')

    # Execute the insert
    begin
      ActiveRecord::Base.connection.execute("INSERT INTO #{table_name} VALUES #{values}")
      puts "  ✓ Loaded data into #{table_name}"
    rescue => e
      puts "  ✗ Error loading #{table_name}: #{e.message}"
    end
  end

  puts "Demo data loaded successfully!"
else
  puts "Warning: Could not find seed file at #{sql_file_path}"
  puts "Creating a test admin user instead..."

  # Fallback: create a simple admin user
  admin_password = Digest::MD5.hexdigest('admin')
  timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  ActiveRecord::Base.connection.execute(<<-SQL)
    INSERT INTO users (username, password, password_hint, created_at, real_name, blab_name, totp_secret)
    VALUES ('admin', '#{admin_password}', 'admin', '#{timestamp}', 'Administrator', 'admin', NULL)
  SQL

  puts "Created admin user (username: admin, password: admin)"
end
