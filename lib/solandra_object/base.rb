require 'jkusar-cassandra_object'
require 'solandra_object/log_subscriber'
require 'active_record/dynamic_finder_match'
require 'active_record/dynamic_scope_match'
require 'solandra_object/errors'
require 'solandra_object/types'

module SolandraObject
  class Base
    include AttributeMethods
    include AttributeMethods::Dirty
    include AttributeMethods::Typecasting
    include Callbacks
    include Connection
    include Consistency
    include Identity
    include FinderMethods
    include Validations
    include Reflection
    include Associations
    include NamedScope
    include Migrations
    include Persistence
    include Timestamps
    
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations::Callbacks
    include ActiveModel::Serializers::JSON
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    extend ActiveSupport::DescendantsTracker
    
    attr_reader :attributes
    attr_accessor :key
    
    def initialize(attributes = {})
      @key = attributes.delete(:key)
      @attributes = {}
      
      @relation = nil
      @new_record = true
      @destroyed = false
      @previously_changed = {}
      @changed_attributes = {}
      @schema_version = self.class.current_schema_version
      
      sanitize_for_mass_assignment(attributes).each do |k,v|
        if respond_to?("#{k.to_s.downcase}=")
          send("#{k.to_s.downcase}=",v)
        else
          raise(UnknownAttributeError, "unknown attribute: #{k}")
        end
      end
    end
    
    def to_param
      id.to_s if persisted?
    end
    
    def hash
      id.hash
    end
    
    def ==(other)
      other.equal(self) ||
      (other.instance_of?(self.class) &&
        other.key == key &&
        !other.new_record?)
    end
    
    def eql?(other)
      self == (other)
    end
    
    # Freeze the attributes hash such that associations are still accessible, even on destroyed records.
    def freeze
      @attributes.freeze; self
    end

    # Returns +true+ if the attributes hash has been frozen.
    def frozen?
      @attributes.frozen?
    end

    class << self
      delegate :first, :all, :exists?, :any?, :many?, :to => :scoped
      delegate :destroy, :destroy_all, :delete, :delete_all, :update, :update_all, :to => :scoped
      # delegate :find_each, :find_in_batches, :to => :scoped
      delegate :order, :limit, :offset, :where, :page, :per_page, :each, :group, :total_pages, :search, :fulltext, :to => :scoped
      delegate :count, :to => :scoped

      def logger
        Rails.logger
      end
      
      def respond_to?(method_id, include_private = false)
        if match = ActiveRecord::DynamicFinderMatch.match(method_id)
          return true if all_attributes_exists?(match.attribute_names)
        elsif match = ActiveRecord::DynamicScopeMatch.match(method_id)
          return true if all_attributes_exists?(match.attribute_names)
        end

        super
      end
      
      def column_family=(column_family)
        @column_family = column_family
      end

      def column_family
        @column_family || name.pluralize
      end

      def base_class
        klass = self
        while klass.superclass != Base
          klass = klass.superclass
        end
        klass
      end
      
      # Returns an array of attribute names as strings
      def attribute_names
        @attribute_names ||= attribute_definitions.keys.collect {|a|a.to_s}
      end
      
      def default_page_size
        30
      end
      
      private
      
        # Enables dynamic finders like <tt>User.find_by_user_name(user_name)</tt> and
        # <tt>User.scoped_by_user_name(user_name).
        #
        # It's even possible to use all the additional parameters to +find+. For example, the
        # full interface for +find_all_by_amount+ is actually <tt>find_all_by_amount(amount, options)</tt>.
        #
        # Each dynamic finder using <tt>scoped_by_*</tt> is also defined in the class after it
        # is first invoked, so that future attempts to use it do not run through method_missing.
        def method_missing(method_id, *arguments, &block)
          if match = ActiveRecord::DynamicFinderMatch.match(method_id)
            attribute_names = match.attribute_names
            super unless all_attributes_exist?(attribute_names)
            if !arguments.first.is_a?(Hash) && arguments.size < attribute_names.size
              ActiveSupport::Deprecation.warn(
                "Calling dynamic finder with less number of arguments than the number of attributes in " \
                "method name is deprecated and will raise an ArguementError in the next version of Rails. " \
                "Please passing `nil' to the argument you want it to be nil."
              )
            end
            if match.finder?
              options = arguments.extract_options!
              relation = options.any? ? scoped(options) : scoped
              relation.send :find_by_attributes, match, attribute_names, *arguments
            elsif match.instantiator?
              scoped.send :find_or_instantiator_by_attributes, match, attribute_names, *arguments, &block
            end
          elsif match = ActiveRecord::DynamicScopeMatch.match(method_id)
            attribute_names = match.attribute_names
            super unless all_attributes_exist?(attribute_names)
            if arguments.size < attribute_names.size
              ActiveSupport::Deprecation.warn(
                "Calling dynamic scope with less number of arguments than the number of attributes in " \
                "method name is deprecated and will raise an ArguementError in the next version of Rails. " \
                "Please passing `nil' to the argument you want it to be nil."
              )
            end
            if match.scope?
              self.class_eval <<-METHOD, __FILE__, __LINE__ + 1
                def self.#{method_id}(*args)                                    # def self.scoped_by_user_name_and_password(*args)
                  attributes = Hash[[:#{attribute_names.join(',:')}].zip(args)] #   attributes = Hash[[:user_name, :password].zip(args)]
                  scoped(:conditions => attributes)                             #   scoped(:conditions => attributes)
                end                                                             # end
                METHOD
              send(method_id, *arguments)
            end
          else
            super
          end
        end
        
        def all_attributes_exist?(attribute_names)
          (attribute_names - self.attribute_names).empty?
        end
        
        def relation #:nodoc:
          @relation ||= Relation.new(self, column_family)
        end
        
      protected
        def current_scope #:nodoc:
          Thread.current["#{self}_current_scope"]
        end
  
        def current_scope=(scope) #:nodoc:
          Thread.current["#{self}_current_scope"] = scope
        end
    end
  end
end
