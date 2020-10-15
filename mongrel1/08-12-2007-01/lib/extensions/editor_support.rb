module Crazy
  module EditorSupport
    def self.included(mod)
      mod.extend(ClassMethods)
    end
    
    module ClassMethods
      def editable
        class_eval do
          extend Crazy::EditorSupport::SingletonMethods
        end
        include Crazy::EditorSupport::InstanceMethods

        class << self
          alias_method_chain :find, :user
          alias_method_chain :validate_find_options, :user
        end
      end
    end
   
    module SingletonMethods
      def validate_find_options_with_user(options)
        (o = options.dup).delete :user
        validate_find_options_without_user(o)
      end
      
      def find_with_user(*args)
        options = extract_options_from_args!(args)
        options = user_find_options(options[:user], options)
        args << options
        find_without_user(*args)
      end
      
      def user_find_options(user, options)
        options
      end
      
      def editor_create(attrs)
        new(attrs)
      end
    end
    
    module InstanceMethods
      def is_viewable_by?(user)
        true
      end
      
      def is_editable_by?(user)
        false
      end
      
      def is_createable_by?(user)
        is_editable_by?(user)
      end
      
      def is_deleteable_by?(user)
        is_editable_by?(user)
      end
      
      def editor_attributes
        attributes
      end
      
      def editor_update_attributes(attrs)
        update_attributes(attrs)
      end
      
      def property_is_viewable_by?(property_name, user)
        editor_attributes.member?(property_name)
      end

      def property_is_editable_by?(property_name, user)
        false
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Crazy::EditorSupport
end
