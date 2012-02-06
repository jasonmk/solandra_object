module SolandraObject
  module NamedScope
    extend ActiveSupport::Concern
    
    module ClassMethods
      def scoped(options = nil)
        if options
          scoped.apply_finder_options(options)
        else
          if current_scope
            current_scope.clone
          else
            relation.clone.tap do |scope|
              scope.default_scoped = true
            end
          end
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
      
      # Collects attributes from scopes that should be applied when creating
      # an SO instance for the particular class this is called on.
      def scope_attributes # :nodoc:
        if current_scope
          current_scope.scope_for_create
        else
          relation.clone.tap do |scope|
            scope.default_scoped = true
          end
        end
      end

      # Are there default attributes associated with this scope?
      def scope_attributes? # :nodoc:
        current_scope || default_scopes.any?
      end
      
      protected
      
        def apply_default_scope
          
        end
      
        def valid_scope_name?(name)
          if respond_to?(name, true)
            logger.warn "Creating scope :#{name}. " \
                        "Overwriting existing method #{self.name}.#{name}."
          end
        end
    end
  end
end