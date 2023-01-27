module FormObject
  def self.included(mod)
    mod.include ActiveModel::Model
    mod.include ActiveModel::Attributes

    mod.include Arrays
  end

  module Arrays
    extend ActiveSupport::Concern

    class_methods do
      def attribute(name, *args, array: false, **options)
        options[:default] ||= [] if array
        super(name, *args, **options)

        define_method(:"#{name}=") do |value|
          super value.reject(&:blank?)
        end
      end
    end
  end
end
