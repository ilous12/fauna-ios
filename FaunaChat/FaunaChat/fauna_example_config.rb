#!/usr/bin/env ruby
DEFAULT_CREDENTIALS_FILE = "FaunaCredentials.h".freeze

begin
  require 'fauna'
rescue LoadError
  $stderr.puts ">> Could not load the fauna gem."
  $stderr.puts ">> Please ensure your ruby enviromnent is configured and the fauna gem installed."
  exit 2
end

creds_file = ARGV[0]
if creds_file.blank?
  creds_file = DEFAULT_CREDENTIALS_FILE
end

email = ENV["FAUNA_TEST_EMAIL"]
password = ENV["FAUNA_TEST_PASSWORD"]

if email && password
  puts "Using Fauna account #{email} for fauna-ios tests."
else
  $stderr.puts ">> Fauna account not configured."
  $stderr.puts ">> FAUNA_TEST_EMAIL and FAUNA_TEST_PASSWORD must be defined in your environment to run tests."
  $stderr.puts ">> One option is to start Xcode with:"
  $stderr.puts ">> $ env FAUNA_TEST_EMAIL=<email> FAUNA_TEST_PASSWORD=<pass> open Fauna-iOS.xcworkspace"
  exit 1
end

root_conn = Fauna::Connection.new(:email => email, :password => password)
root_conn.delete("everything")

publisher_key = root_conn.post("keys/publisher")['resource']['key']
client_key = root_conn.post("keys/client")['resource']['key']

puts "Added publisher key #{publisher_key}"
puts "Added client key #{client_key}"

Fauna.schema do |f|
  with :class_name => "classes/message" do
    event_set "chat"
  end
end

Fauna::Client.context(Fauna::Connection.new(:publisher_key => publisher_key)) do
  Fauna.migrate_schema!
end

puts "Writing credentials file #{creds_file}"

File.open(creds_file, 'w') do |f|
  f.puts <<-EOF
  #ifndef FAUNA_CREDENTIALS_h
  #define FAUNA_CREDENTIALS_h

  #define FAUNA_PUBLISHER_KEY @"#{publisher_key}"
  #define FAUNA_CLIENT_KEY @"#{client_key}"

  #endif
  EOF

end
