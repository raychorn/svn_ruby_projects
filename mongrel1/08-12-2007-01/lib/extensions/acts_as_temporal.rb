module Crazy
  module Acts
    module Temporal
      def self.included(mod)
        mod.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_temporal
          class_eval do
            extend Crazy::Acts::Temporal::SingletonMethods
          end
          include Crazy::Acts::Temporal::InstanceMethods

          class << self
            alias_method_chain :find, :time_parameter
          end
        end
      end
     
      module SingletonMethods
        class TemporalClassProxy
          attr_reader :vintage
          
          def initialize(real_class, vintage)
            @real_class = real_class
            @vintage = vintage
          end
          
          def reflections
            refs = @real_class.reflections.dup
            refs.each do |k, v|
              if refs[k].klass.respond_to? :find_with_time_parameter
                refs[k] = TemporalReflectionProxy.new(refs[k], @vintage)
              end                
            end
          end
          
          def method_missing(meth, *args)
            @real_class.send(meth, *args)
          end
        end
        
        class TemporalReflectionProxy
          attr_reader :vintage
          
          def initialize(real_obj, vintage)
            @real_obj = real_obj
            @vintage = vintage
          end
          
          def klass
            k = super
            k.respond_to?(:find_with_time_parameter) ? TemporalClassProxy.new(k, @vintage) : k
          end
          
          def options
            @options ||=
              returning o = @real_obj.options.dup do
                case @real_obj.macro
                when :has_and_belongs_to_many
                  join_table_name = @real_obj.options[:join_table]
                when :has_many
                  join_table_name = @real_obj.klass.table_name
                end
                o[:conditions] = ["(#{join_table_name}.valid_from <= ? AND (#{join_table_name}.valid_to > ? OR #{join_table_name}.valid_to IS NULL))", @vintage, @vintage]
              end
          end

          def method_missing(meth, *args)
            @real_obj.send(meth, *args)
          end
        end
        
        def validate_find_options(options)
          (o = options.dup).delete :time
          super(o)
        end
        
        def find_with_time_parameter(*args)
          options = extract_options_from_args!(args)
        
          options[:time] ||= Time.now
          target_time = options[:time]

          args << options
          returning find_without_time_parameter(*args) do |m|
            case m
            when Array
              m.each { |match| match.vintage = target_time }
            when nil
              nil
            else
              m.vintage = target_time
            end
          end
        end
        
        private
        def find_with_associations(options = {})
          catch :invalid_query do
            join_dependency = ActiveRecord::Associations::ClassMethods::JoinDependency.new(TemporalClassProxy.new(self, options[:time]), merge_includes(scope(:find, :include), options[:include]), options[:joins])
            rows = select_all_rows(options, join_dependency)
            return join_dependency.instantiate(rows)
          end
          []
        end
      end
      
      module InstanceMethods
        def vintage
          @vintage
        end
        
        def vintage=(t)
          @vintage = t
        end
      end
    end
  end
  
  module Associations
    class HasManyTemporalAssociation < ActiveRecord::Associations::HasManyAssociation
      def find(what, options = {})
        options[:time] = @owner.vintage if @reflection.klass.respond_to? :find_with_time_parameter
        super(what, options)
      end
      
      def conditions
        base_conditions = super
        table_name = @reflection.klass.table_name
        my_conditions = sanitize_sql ["#{table_name}.valid_from <= ? AND (#{table_name}.valid_to > ? OR #{table_name}.valid_to IS NULL)", @owner.vintage, @owner.vintage]
        
        if base_conditions
          "#({base_conditions}) AND #{my_conditions}"
        else
          my_conditions
        end
      end
    end
    
    class HasAndBelongsToManyTemporalAssociation < ActiveRecord::Associations::HasAndBelongsToManyAssociation
      def find(what, options = {})
        options[:time] = @owner.vintage if @reflection.klass.respond_to? :find_with_time_parameter
        super(what, options)
      end
      
      def conditions
        @conditions ||= begin
          base_conditions = super
          join_table = @reflection.options[:join_table]
          my_conditions = sanitize_sql ["#{join_table}.valid_from <= ? AND (#{join_table}.valid_to > ? OR #{join_table}.valid_to IS NULL)",
                                        @owner.vintage, @owner.vintage]
        
          if base_conditions
            "#({base_conditions}) AND #{my_conditions}"
          else
            my_conditions
          end
        end
      end
    end

    class BelongsToTemporalAssociation < HasAndBelongsToManyTemporalAssociation
      def find_target
        t = super
        t = t.nil? ? t : t[0]
        t.vintage = @owner.vintage if t.respond_to?(:vintage=)
        t
      end
    end
        
    def self.included(mod)
      mod.extend(ClassMethods)
    end
    
    module ClassMethods
      def has_many_temporal(association_id, options = {}, &extension)
        reflection = create_has_many_reflection(association_id, options, &extension)
        collection_reader_method(reflection, HasManyTemporalAssociation)
      end
  
      def has_and_belongs_to_many_temporal(association_id, options = {}, &extension)
        reflection = create_has_and_belongs_to_many_reflection(association_id, options, &extension)
        collection_reader_method(reflection, HasAndBelongsToManyTemporalAssociation)
      end
      
      def belongs_to_temporal(association_id, options = {})
        reflection = create_has_and_belongs_to_many_reflection(association_id, options)
        reflection.options[:temporal] = :belongs_to
        association_accessor_methods(reflection, BelongsToTemporalAssociation)
        remove_method "#{reflection.name}="
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Crazy::Acts::Temporal
  include Crazy::Associations
end

class ActiveRecord::Associations::ClassMethods::JoinDependency
  def construct_association_with_temporal_hackery(record, join, row)
    if (join.reflection.macro == :has_and_belongs_to_many &&
        join.reflection.options[:temporal] == :belongs_to)
      return nil if record.id.to_s != join.parent.record_id(row).to_s or row[join.aliased_primary_key].nil?
      association = join.instantiate(row)
      record.send("set_#{join.reflection.name}_target", association)
    else
      association = construct_association_without_temporal_hackery(record, join, row)
    end
    
    if association.respond_to?(:vintage=) && join.reflection.respond_to?(:vintage)
      association.vintage = join.reflection.vintage
    end
    association
  end
  
  alias_method_chain :construct_association, :temporal_hackery
end
