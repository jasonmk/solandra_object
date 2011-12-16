require 'jkusar-cassandra_object'
require 'active_record/dynamic_finder_match'
module SolandraObject
  class Base < ::CassandraObject::Base
    include AttributeMethods
    include Validations
    include Reflection
    include Associations
    include NamedScope
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations::Callbacks
    
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
      delegate :order, :limit, :offset, :where, :page, :per_page, :each, :group, :total_pages, :to => :scoped
      delegate :count, :to => :scoped
      
      # Enables dynamic finders like <tt>User.find_by_user_name(user_name)</tt> and
      # <tt>User.scoped_by_user_name(user_name). Refer to Dynamic attribute-based finders
      # section at the top of this file for more detailed information.
      #
      # It's even possible to use all the additional parameters to +find+. For example, the
      # full interface for +find_all_by_amount+ is actually <tt>find_all_by_amount(amount, options)</tt>.
      #
      # Each dynamic finder using <tt>scoped_by_*</tt> is also defined in the class after it
      # is first invoked, so that future attempts to use it do not run through method_missing.
      # def method_missing(method_id, *arguments, &block)
      #   if match = (DynamicFinderMatch.match(method_id) || DynamicScopeMatch.match(method_id))
      #     attribute_names = match.attribute_names
      #     super unless all_attributes_exists?(attribute_names)
      #     if arguments.size < attribute_names.size
      #       method_trace = "#{__FILE__}:#{__LINE__}:in `#{method_id}'"
      #       backtrace = [method_trace] + caller
      #       raise ArgumentError, "wrong number of arguments (#{arguments.size} for #{attribute_names.size})", backtrace
      #     end
      #     if match.respond_to?(:scope?) && match.scope?
      #       self.class_eval <<-METHOD, __FILE__, __LINE__ + 1
      #         def self.#{method_id}(*args)                                    # def self.scoped_by_user_name_and_password(*args)
      #           attributes = Hash[[:#{attribute_names.join(',:')}].zip(args)] #   attributes = Hash[[:user_name, :password].zip(args)]
      #                                                                         #
      #           scoped(:conditions => attributes)                             #   scoped(:conditions => attributes)
      #         end                                                             # end
      #         METHOD
      #       send(method_id, *arguments)
      #     elsif match.finder?
      #       options = arguments.extract_options!
      #       relation = options.any? ? scoped(options) : scoped
      #       relation.send :find_by_attributes, match, attribute_names, *arguments, &block
      #     elsif match.instantiator?
      #       scoped.send :find_or_instantiator_by_attributes, match, attribute_names, *arguments, &block
      #     end
      #   else
      #     super
      #   end
      # end
      
      private
        def relation #:nodoc:
          @relation = Relation.new(self, column_family)
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