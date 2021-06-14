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
    message.in?(devise_messages) ? DEVISE_FLASH_VARIANT_MAPPING[variant.to_sym] : variant
  end

  private

  def devise_messages
    get_nested_values(I18n.t("devise"))
  end

  def get_nested_values(hash)
    hash.respond_to?(:values) ? hash.values.map { |value| get_nested_values(value) }.flatten : hash
  end
end
