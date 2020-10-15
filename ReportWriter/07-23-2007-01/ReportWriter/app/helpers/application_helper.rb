# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    class EnvironmentChecker
        def isEnvironmentDevelopment?
            ENV['RAILS_ENV'] == 'development'      
        end
    end
end
