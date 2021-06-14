module DeviseFlashConcerns
  extend ActiveSupport::Concern

  DEVISE_FLASH_VARIANT_MAPPING = {
    alert: "notice",
    notice: "success",
  }.freeze

  included do
    helper_method :convert_devise_flash_variant
  end

  def convert_devise_flash_variant(variant, message)
    if message.in?(devise_messages)
      DEVISE_FLASH_VARIANT_MAPPING[variant.to_sym]
    else
      variant
    end
  end

  private

  def devise_messages
    get_nested_values(I18n.t("devise"))
  end

  def get_nested_values(hash)
    return hash unless hash.respond_to?(:values)

    hash.values.map { |value| get_nested_values(value) }.flatten
  end
end
