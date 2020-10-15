if ENV['RAILS_ENV'] == 'development'
  # Fix a bug in ActiveRecord that is triggered by a class getting reloaded without
  # the association also being updated.
  #
  # Because classes are only reloaded between requests in development mode,
  # we only need to apply the fix in this case.

  require 'active_record/associations/association_proxy'

  module ActiveRecord
    module Associations
      class AssociationProxy
        def raise_on_type_mismatch(record)
          unless record.class.name == @reflection.class_name
            raise ActiveRecord::AssociationTypeMismatch, "#{@reflection.class_name} expected, got #{record.class}"
          end
        end
      end
    end
  end
end
