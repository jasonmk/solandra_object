require 'jkusar-cassandra_object'
module SolandraObject
  class Base < ::CassandraObject::Base
    include AttributeMethods
    include Validations
    include Reflection
    include Associations
    include ActiveModel::MassAssignmentSecurity
    
    def initialize(attributes = nil, options = {})
      sanitize_for_mass_assignment(attributes).each do |k,v|
        if respond_to?("#{k.downcase}=")
          send("#{k.downcase}=",v)
        else
          raise(UnknownAttributeError, "unknown attribute: #{k}")
        end
      end
      @relation = nil
      @new_record = true
      @destroyed = false
      @previously_changed = {}
      @changed_attributes = {}
    end
    
    class << self
      delegate :first, :all, :exists?, :any?, :many?, :to => :scoped
      delegate :destroy, :destroy_all, :delete, :delete_all, :update, :update_all, :to => :scoped
      delegate :find_each, :find_in_batches, :to => :scoped
      delegate :order, :limit, :offset, :where, :to => :scoped
      delegate :count, :to => :scoped
      
      def scoped
        if current_scope
          current_scope.clone
        else
          relation.clone
        end
      end
      
      # Enables dynamic finders like <tt>User.find_by_user_name(user_name)</tt> and
      # <tt>User.scoped_by_user_name(user_name). Refer to Dynamic attribute-based finders
      # section at the top of this file for more detailed information.
      #
      # It's even possible to use all the additional parameters to +find+. For example, the
      # full interface for +find_all_by_amount+ is actually <tt>find_all_by_amount(amount, options)</tt>.
      #
      # Each dynamic finder using <tt>scoped_by_*</tt> is also defined in the class after it
      # is first invoked, so that future attempts to use it do not run through method_missing.
      def method_missing(method_id, *arguments, &block)
        
      end
    end
    
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