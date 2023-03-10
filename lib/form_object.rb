module FormObject
  def self.included(mod)
    mod.include ActiveModel::Model
    mod.include ActiveModel::Attributes
    mod.include ActiveModel::Validations::Callbacks
    mod.include ActiveModel::Dirty

    mod.include Arrays
  end

  def initialize(*, **)
    super

    clear_changes_information
  end

  module Arrays
    extend ActiveSupport::Concern

    class_methods do
      def attribute(name, *args, array: false, **options)
        options[:default] ||= -> { [] } if array
        super(name, *args, **options)
        return unless array

        mod = Module.new do
          define_method(:"#{name}=") do |value|
            super value&.reject(&:blank?) || []
          end
        end

        include mod
      end
    end
  end
end
