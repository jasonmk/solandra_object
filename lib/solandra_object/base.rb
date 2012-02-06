require 'jkusar-cassandra_object'
require 'active_record/dynamic_finder_match'
require 'active_record/dynamic_scope_match'
module SolandraObject #:nodoc:
  # = Solandra Object
  #
  # Solandra Object-based objects differ from Active Record objects in that they specify their
  # attributes directly on the model.  This is necessary because of the fact that Cassandra
  # column families do not have a set list of columns but rather can have different columns per
  # row.  By specifying the attributes on the model, getters and setters are automatically
  # created, and the attribute is automatically indexed into SOLR.
  #
  # == Creation
  #
  # Solandra Objects accept constructor parameters either in a hash or as a block. The hash
  # method is especially useful when you're receiving the data from somewhere else, like an
  # HTTP request. It works like this:
  #
  #   user = User.new(:name => "David", :occupation => "Code Artist")
  #   user.name # => "David"
  #
  # You can also use block initialization:
  #
  #   user = User.new do |u|
  #     u.name = "David"
  #     u.occupation = "Code Artist"
  #   end
  #
  # And of course you can just create a bare object and specify the attributes after the fact:
  #
  #   user = User.new
  #   user.name = "David"
  #   user.occupation = "Code Artist"
  #
  # == Conditions
  #
  # Conditions are specified as a hash representing key/value pairs that will eventually be passed to Sunspot or as
  # a chained call for greater_than and less_than conditions.  In addition, fulltext queries may be specified as a
  # string that will eventually be parsed by SOLR as a standard SOLR query.
  #
  # A simple hash without a statement will generate conditions based on equality using boolean AND logic.
  # For instance:
  #
  #   Student.where(:first_name => "Harvey", :status => 1)
  #   Student.where(params[:student])
  #
  # A range may be used in the hash to use a SOLR range query:
  #
  #   Student.where(:grade => 9..12)
  #
  # An array may be used in the hash to construct a SOLR OR query:
  #
  #   Student.where(:grade => [9,11,12])
  #
  # Inequality can be tested for like so:
  #
  #   Student.where_not(:grade => 9)
  #   Student.where(:grade).greater_than(9)
  #   Student.where(:grade).less_than(10)
  #
  # Fulltext searching is natively supported.  All text and string fields are automatically indexed for fulltext
  # searching.
  #
  #   Post.fulltext('Apple AND "iPhone 4s"')
  #
  # Fulltext searching uses the standard Lucene query parser.  If you want to use the newer disMax query parser,
  # you can specify it like so:
  #
  #   Post.fulltext('Apple iPhone 4s').query_parser('disMax')
  #
  # For a full discussion of the differences between the two query parsers, see the SOLR documentation:
  # https://wiki.apache.org/solr/SolrQuerySyntax
  #
  # == Overwriting default accessors
  #
  # All column values are automatically available through basic accessors on the Solandra Object,
  # but sometimes you want to specialize this behavior. This can be done by overwriting
  # the default accessors (using the same name as the attribute) and calling
  # <tt>read_attribute(attr_name)</tt> and <tt>write_attribute(attr_name, value)</tt> to actually
  # change things.
  #
  #   class Song < SolandraObject::Base
  #     # Uses an integer of seconds to hold the length of the song
  #
  #     def length=(minutes)
  #       write_attribute(:length, minutes.to_i * 60)
  #     end
  #
  #     def length
  #       read_attribute(:length) / 60
  #     end
  #   end
  #
  # You can alternatively use <tt>self[:attribute]=(value)</tt> and <tt>self[:attribute]</tt>
  # instead of <tt>write_attribute(:attribute, value)</tt> and <tt>read_attribute(:attribute)</tt>.
  #
  # == Dynamic attribute-based finders
  #
  # Dynamic attribute-based finders are a cleaner way of getting (and/or creating) objects
  # by simple queries without using where chains. They work by appending the name of an attribute
  # to <tt>find_by_</tt> or <tt>find_all_by_</tt> and thus produces finders
  # like <tt>Person.find_by_user_name</tt>, <tt>Person.find_all_by_last_name</tt>, and
  # <tt>Payment.find_by_transaction_id</tt>. Instead of writing
  # <tt>Person.where(:user_name => user_name).first</tt>, you just do <tt>Person.find_by_user_name(user_name)</tt>.
  # And instead of writing <tt>Person.where(:last_name => last_name).all</tt>, you just do
  # <tt>Person.find_all_by_last_name(last_name)</tt>.
  #
  # It's also possible to use multiple attributes in the same find by separating them with "_and_".
  #
  #   Person.where(:user_name => user_name, :password => password).first
  #   Person.find_by_user_name_and_password(user_name, password) # with dynamic finder
  #
  # It's even possible to call these dynamic finder methods on relations and named scopes.
  #
  #   Payment.order("created_on").find_all_by_amount(50)
  #   Payment.pending.find_last_by_amount(100)
  #
  # The same dynamic finder style can be used to create the object if it doesn't already exist.
  # This dynamic finder is called with <tt>find_or_create_by_</tt> and will return the object if
  # it already exists and otherwise creates it, then returns it. Protected attributes won't be set
  # unless they are given in a block.
  #
  # NOTE: This functionality is currently unimplemented but will be in a release in the near future.
  #
  #   # No 'Summer' tag exists
  #   Tag.find_or_create_by_name("Summer") # equal to Tag.create(:name => "Summer")
  #
  #   # Now the 'Summer' tag does exist
  #   Tag.find_or_create_by_name("Summer") # equal to Tag.find_by_name("Summer")
  #
  #   # Now 'Bob' exist and is an 'admin'
  #   User.find_or_create_by_name('Bob', :age => 40) { |u| u.admin = true }
  #
  # Use the <tt>find_or_initialize_by_</tt> finder if you want to return a new record without
  # saving it first. Protected attributes won't be set unless they are given in a block.
  #
  #   # No 'Winter' tag exists
  #   winter = Tag.find_or_initialize_by_name("Winter")
  #   winter.persisted? # false
  #
  # Just like <tt>find_by_*</tt>, you can also use <tt>scoped_by_*</tt> to retrieve data. The good thing about
  # using this feature is that the very first time result is returned using <tt>method_missing</tt> technique
  # but after that the method is declared on the class. Henceforth <tt>method_missing</tt> will not be hit.
  #
  #   User.scoped_by_user_name('David')
  #
  # == Exceptions
  #
  # * SolandraObjectError - Generic error class and superclass of all other errors raised by Solandra Object.
  # * AssociationTypeMismatch - The object assigned to the association wasn't of the type
  #   specified in the association definition.
  # * ConnectionNotEstablished+ - No connection has been established. Use <tt>establish_connection</tt>
  #   before querying.
  # * RecordNotFound - No record responded to the +find+ method. Either the row with the given ID doesn't exist
  #   or the row didn't meet the additional restrictions. Some +find+ calls do not raise this exception to signal
  #   nothing was found, please check its documentation for further details.
  # * MultiparameterAssignmentErrors - Collection of errors that occurred during a mass assignment using the
  #   <tt>attributes=</tt> method. The +errors+ property of this exception contains an array of
  #   AttributeAssignmentError objects that should be inspected to determine which attributes triggered the errors.
  # * AttributeAssignmentError - An error occurred while doing a mass assignment through the
  #   <tt>attributes=</tt> method.
  #   You can inspect the +attribute+ property of the exception object to determine which attribute
  #   triggered the error.
  #
  # See the documentation for SearchMethods for more examples of using the search API.
  class Base < ::CassandraObject::Base
    include AttributeMethods
    include CassandraFinderMethods
    include Validations
    include Reflection
    include Associations
    include NamedScope
    include Persistence
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations::Callbacks
    
    # Stores the default scope for the class
    class_attribute :default_scopes, :instance_writer => false
    self.default_scopes = []
    
    def initialize(attributes = {})
      @key = attributes.delete(:key)
      @attributes = {}
      
      @relation = nil
      @new_record = true
      @destroyed = false
      @previously_changed = {}
      @changed_attributes = {}
      @schema_version = self.class.current_schema_version
      
      populate_with_current_scope_attributes
      
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
    
    private
      def populate_with_current_scope_attributes
        return unless self.class.scope_attributes?
        
        self.class.scope_attributes.each do |att, value|
          send("#{att}=", value) if respond_to?("#{att}=")
        end
      end

    class << self
      delegate :first, :all, :exists?, :any?, :many?, :to => :scoped
      delegate :destroy, :destroy_all, :delete, :delete_all, :update, :update_all, :to => :scoped
      # delegate :find_each, :find_in_batches, :to => :scoped
      delegate :order, :limit, :offset, :where, :page, :paginate, :per_page, :each, :group, :total_pages, :search, :fulltext, :to => :scoped
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
      
      # Returns an array of attribute names as strings
      def attribute_names
        @attribute_names ||= attribute_definitions.keys.collect {|a|a.to_s}
      end
      
      # SOLR always paginates all requests.  There is no way to disable it, so we are
      # setting the default page size to an arbitrarily high number so that we effectively
      # remove pagination.  If you instead want a model set to something more sane, then
      # override this method in your model and set it.  Of course, the page size can
      # always be raised or lowered for an individual request.
      #
      #   class Model < SolandraObject::Base
      #     def self.default_page_size
      #       30
      #     end
      #   end
      def default_page_size
        100000
      end
      
      def search_ids(&block)
        search = solr_search(&block)
        search.raw_results.map { |result| result.primary_key }
      end
      
      protected
      
        # Returns a scope for this class without taking into account the default_scope.
        #
        #   class Post < SolandraObject::Base
        #     def self.default_scope
        #       where :published => true
        #     end
        #   end
        #
        #   Post.all # Finds posts where +published+ is +true+
        #   Post.unscoped.all # Finds all posts regardless of +published+'s truthiness
        #
        # This method also accepts a block meaning that all queries inside the block will
        # not use the default_scope:
        #
        #   Post.unscoped {
        #     Post.limit(10) # Finds the first 10 posts
        #   }
        #
        # It is recommended to use block form of unscoped because chaining unscoped with <tt>scope</tt>
        # does not work. Assuming that <tt>published</tt> is a <tt>scope</tt> following two statements are same.
        #
        #   Post.unscoped.published
        #   Post.published
        def unscoped #:nodoc:
          block_given? ? relation.scoping { yield } : relation
        end
        
        # with_scope lets you apply options to inner block incrementally. It takes a hash and the keys must be
        # <tt>:find</tt> or <tt>:create</tt>. <tt>:find</tt> parameter is <tt>Relation</tt> while
        # <tt>:create</tt> parameters are an attributes hash.
        #
        #   class Article < SolandraObject::Base
        #     def self.create_with_scope
        #       with_scope(:find => where(:blog_id => 1), :create => { :blog_id => 1 }) do
        #         find(1) # => WHERE blog_id = 1 AND id = 1
        #         a = create(1)
        #         a.blog_id # => 1
        #       end
        #     end
        #   end
        #
        # In nested scopings, all previous parameters are overwritten by the innermost rule, with the exception of
        # <tt>where</tt> which is merged.
        #
        # You can ignore any previous scopings by using the <tt>with_exclusive_scope</tt> method.
        #
        #   class Article < SolandraObject::Base
        #     def self.find_with_exclusive_scope
        #       with_scope(:find => where(:blog_id => 1).limit(1)) do
        #         with_exclusive_scope(:find => limit(10)) do
        #           all # => SELECT * from articles LIMIT 10
        #         end
        #       end
        #     end
        #   end
        #
        # *Note*: the +:find+ scope also has effect on update and deletion methods, like +update_all+ and +delete_all+.
        def with_scope(scope = {}, action = :merge, &block)
          # If another SolandraObject class has been passed in, get its current scope
          scope = scope.current_scope if !scope.is_a?(Relation) && scope.respond_to?(:current_scope)

          previous_scope = self.current_scope

          if scope.is_a?(Hash)
            # Dup first and second level of hash (method and params).
            scope = scope.dup
            scope.each do |method, params|
              scope[method] = params.dup unless params == true
            end

            scope.assert_valid_keys([ :find, :create ])
            relation = construct_finder_relation(scope[:find] || {})
            relation.default_scoped = true unless action == :overwrite

            if previous_scope && previous_scope.create_with_value && scope[:create]
              scope_for_create = if action == :merge
                previous_scope.create_with_value.merge(scope[:create])
              else
                scope[:create]
              end

              relation = relation.create_with(scope_for_create)
            else
              scope_for_create = scope[:create]
              scope_for_create ||= previous_scope.create_with_value if previous_scope
              relation = relation.create_with(scope_for_create) if scope_for_create
            end

            scope = relation
          end

          scope = previous_scope.merge(scope) if previous_scope && action == :merge

          self.current_scope = scope
          begin
            yield
          ensure
            self.current_scope = previous_scope
          end
        end
        
        # Works like with_scope, but discards any nested properties.
        def with_exclusive_scope(method_scoping = {}, &block)
          if method_scoping.values.any? { |e| e.is_a?(SolandraObject::Relation) }
            raise ArgumentError, <<-MSG
New finder API can not be used with_exclusive_scope. You can either call unscoped to get an anonymous scope not bound to the default_scope:

User.unscoped.where(:active => true)

Or call unscoped with a block:

User.unscoped do
User.where(:active => true).all
end

MSG
          end
          with_scope(method_scoping, :overwrite, &block)
        end
        
        # Use this macro in your model to set a default scope for all operations on
        # the model.
        #
        #   class Article < SolandraObject::Base
        #     default_scope where(:published => true)
        #   end
        #
        #   Article.all # => all articles where published = true
        #
        # The <tt>default_scope</tt> is also applied while creating/building a record. It is not
        # applied while updating a record.
        #
        #   Article.new.published # => true
        #   Article.create.published # => true
        #
        # You can also use <tt>default_scope</tt> with a block, in order to have it lazily evaluated:
        #
        #   class Article < SolandraObject::Base
        #     default_scope { where(:published_at => Time.now - 1.week) }
        #   end
        #
        # (You can also pass any object which responds to <tt>call</tt> to the <tt>default_scope</tt>
        # macro, and it will be called when building the default scope.)
        #
        # If you use multiple <tt>default_scope</tt> declarations in your model then they will
        # be merged together:
        #
        #   class Article < SolandraObject::Base
        #     default_scope where(:published => true)
        #     default_scope where(:rating => 'G')
        #   end
        #
        # Article.all # => all articles where published = true AND rating = 'G'
        #
        # This is also the case with inheritance and module includes where the parent or module
        # defines a <tt>default_scope</tt> and the child or including class defines a second one.
        #
        # If you need to do more complex things with a default scope, you can alternatively
        # define it as a class method:
        #
        #   class Article < SolandraObject::Base
        #     def self.default_scope
        #       # Should return a scope, you can call 'super' here etc.
        #     end
        #   end
        def default_scope(scope = {})
          scope = Proc.new if block_given?
          self.default_scopes = default_scopes + [scope]
        end

        def build_default_scope #:nodoc:
          if method(:default_scope).owner != Base.singleton_class
            evaluate_default_scope { default_scope }
          elsif default_scopes.any?
            evaluate_default_scope do
              default_scopes.inject(relation) do |default_scope, scope|
                if scope.is_a?(Hash)
                  default_scope.apply_finder_options(scope)
                elsif !scope.is_a?(Relation) && scope.respond_to?(:call)
                  default_scope.merge(scope.call)
                else
                  default_scope.merge(scope)
                end
              end
            end
          end
        end

        def ignore_default_scope? #:nodoc:
          Thread.current["#{self}_ignore_default_scope"]
        end

        def ignore_default_scope=(ignore) #:nodoc:
          Thread.current["#{self}_ignore_default_scope"] = ignore
        end

        # The ignore_default_scope flag is used to prevent an infinite recursion situation where
        # a default scope references a scope which has a default scope which references a scope...
        def evaluate_default_scope
          return if ignore_default_scope?

          begin
            self.ignore_default_scope = true
            yield
          ensure
            self.ignore_default_scope = false
          end
        end
      
      private
      
        def construct_finder_relation(options = {}, scope = nil)
          relation = options.is_a(Hash) ? unscoped.apply_finder_options(options) : options
          relation = scope.merge(relation) if scope
          relation
        end
      
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
