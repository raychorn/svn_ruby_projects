require 'parsedate'

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      # Converting strings to other objects
      module Conversions
        # Form can be either :utc (default) or :local.
        def to_time(form = :utc)
          ::Time.send("#{form}_time", *ParseDate.parsedate(self)[0..5].map {|arg| arg || 0})
        end

        def to_date
          ::Date.new(*ParseDate.parsedate(self)[0..2])
        end
        
        def to_datetime
          ::DateTime.civil(*ParseDate.parsedate(self)[0..5].map {|arg| arg || 0} << 0 << 0)
        end
      end
    end
  end
end