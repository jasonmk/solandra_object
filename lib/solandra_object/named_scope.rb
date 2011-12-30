module SolandraObject
  module NamedScope
    extend ActiveSupport::Concern
    
    module ClassMethods
      def scoped
        if current_scope
          current_scope.clone
        else
          relation.clone
        end
      end
      
      # Allows the creation of named scopes
      def scope(name, scope_options = {})
        name = name.to_sym
        valid_scope_name?(name)
        extension = Module.new(&Proc.new) if block_given?

        scope_proc = lambda do |*args|
          options = scope_options.respond_to?(:call) ? scope_options.call(*args) : scope_options
          options = scoped.apply_finder_options(options) if options.is_a?(Hash)

          relation = scoped.merge(options)

          extension ? relation.extending(extension) : relation
        end

        singleton_class.send(:redefine_method, name, &scope_proc)
      end
      
      def unscoped
        scoped.default_scope
      end
      
      protected
      
        def apply_default_scope
          
        end
      
        # with_scope lets you apply options to inner block incrementally. It takes a hash and the keys must be
        # <tt>:find</tt> or <tt>:create</tt>. <tt>:find</tt> parameter is <tt>Relation</tt> while
        # <tt>:create</tt> parameters are an attributes hash.
        #
        #   class Article < SolandraObject::Base
        #     def self.create_with_scope
        #       with_scope(:find => where(:blog_id, 1), :create => { :blog_id => 1 }) do
        #         find(1) # => SELECT * from articles WHERE blog_id = 1 AND id = 1
        #         a = create(1)
        #         a.blog_id # => 1
        #       end
        #     end
        #   end
        #
        # In nested scopings, all previous parameters are overwritten by the innermost rule, with the exception of
        # <tt>where</tt> operations in <tt>Relation</tt>, which are merged.
        #
        #   class Article < SolandraObject::Base
        #     def self.find_with_scope
        #       with_scope(:find => where(:blog_id => 1).limit(1), :create => { :blog_id => 1 }) do
        #         with_scope(:find => limit(10)) do
        #           all # => SELECT * from articles WHERE blog_id = 1 LIMIT 10
        #         end
        #         with_scope(:find => where(:author_id => 3)) do
        #           all # => SELECT * from articles WHERE blog_id = 1 AND author_id = 3 LIMIT 1
        #         end
        #       end
        #     end
        #   end
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
        # def with_scope(scope = {}, action = :merge, &block)
          # # If another Active Record class has been passed in, get its current scope
          # scope = scope.current_scope if !scope.is_a?(Relation) && scope.respond_to?(:current_scope)
# 
          # previous_scope = self.current_scope
# 
          # if scope.is_a?(Hash)
            # # Dup first and second level of hash (method and params).
            # scope = scope.dup
            # scope.each do |method, params|
              # scope[method] = params.dup unless params == true
            # end
# 
            # scope.assert_valid_keys([ :find, :create ])
            # relation = construct_finder_arel(scope[:find] || {})
            # relation.default_scoped = true unless action == :overwrite
# 
            # if previous_scope && previous_scope.create_with_value && scope[:create]
              # scope_for_create = if action == :merge
                # previous_scope.create_with_value.merge(scope[:create])
              # else
                # scope[:create]
              # end
# 
              # relation = relation.create_with(scope_for_create)
            # else
              # scope_for_create = scope[:create]
              # scope_for_create ||= previous_scope.create_with_value if previous_scope
              # relation = relation.create_with(scope_for_create) if scope_for_create
            # end
# 
            # scope = relation
          # end
# 
          # scope = previous_scope.merge(scope) if previous_scope && action == :merge
# 
          # self.current_scope = scope
          # begin
            # yield
          # ensure
            # self.current_scope = previous_scope
          # end
        # end



        def valid_scope_name?(name)
          if respond_to?(name, true)
            logger.warn "Creating scope :#{name}. " \
                        "Overwriting existing method #{self.name}.#{name}."
          end
        end
    end
  end
end