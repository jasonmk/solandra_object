module SolandraObject
  module NamedScope
    extends ActiveSupport::Concern
    
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
      
      protected

        def valid_scope_name?(name)
          if respond_to?(name, true)
            logger.warn "Creating scope :#{name}. " \
                        "Overwriting existing method #{self.name}.#{name}."
          end
        end
    end
  end
end