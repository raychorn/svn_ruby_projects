require 'weborb/log'
require 'weborb/config/weborb_config'

if Log.info?
  Log.info( "loading WebORB Configuration" )
end

if ENV['RAILS_ENV'] == 'development'
  Dependencies.mechanism = :load
end

WebORBConfig.init