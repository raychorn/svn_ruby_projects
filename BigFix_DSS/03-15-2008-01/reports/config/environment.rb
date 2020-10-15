# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

_requiredGems = ["imagesize-0.1.1", "pdf-writer-1.1.3"]

puts "** Checking to make sure all required GEMS have been properly loaded...\n"
c = ::Config::CONFIG
ra = c['bindir'].to_s.gsub('/','\\').split("\\")
ra.delete_at(ra.length - 1)
fName = ra.join("\\") + "\\lib\\ruby\\gems\\1.8\\gems\\"
begin
    rgDir = Dir.new(fName)
rescue
    rgDir = Dir.new(fName.gsub('\\', '/'))
end
requiredGems = Array.new
rgDir.each {|x| z = []; _requiredGems.each{|a| z.push(a) if (x.include?(a)) }; requiredGems.push(x) if (z.length > 0)  }
raise Exception.new("Invalid configuration - Missing GEMS named 'imagesize' and 'pdf-writer' - Please ensure your Ruby is properly configuired with these required GEMS and then try again...") if (requiredGems.length < 2)
puts "** All required GEMS have been loaded !\n"

Rails::Initializer.run do |config|
	# Settings in config/environments/* take precedence over those specified here

	# Skip frameworks you're not going to use (only works if using vendor/rails)
	# config.frameworks -= [ :action_web_service, :action_mailer ]

	# Only load the plugins named here, by default all plugins in vendor/plugins are loaded
	# config.plugins = %W( exception_notification ssl_requirement )

	# Add additional load paths for your own custom dirs
	# config.load_paths += %W( #{RAILS_ROOT}/extras )
	config.load_paths += ["#{RAILS_ROOT}/lib/extensions"]

	# Force all environments to use the same logger level
	# (by default production uses :info, the others :debug)
	# config.log_level = :debug

	# Use the database for sessions instead of the file system
	# (create the session table with 'rake db:sessions:create')
	# config.action_controller.session_store = :active_record_store

	# Use SQL instead of Active Record's schema dumper when creating the test database.
	# This is necessary if your schema can't be completely dumped by the schema dumper,
	# like if you have constraints or database-specific column types
	# config.active_record.schema_format = :sql

	# Activate observers that should always be running
	# config.active_record.observers = :cacher, :garbage_collector

	# Make Active Record use UTC-base instead of local time
	# config.active_record.default_timezone = :utc

	# See Rails::Configuration for more options
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Add custom extensions to core types.
require 'core_ext'

# Fix bugs in Rails.
require 'bugfixes'

require 'active_record_extension.rb'

# Include your application configuration below

if false
	require 'weborb/log'
	require 'weborb/constants'

	class Log
		class << self
			@@log_level = Constants::INFO
		end
	end
end

