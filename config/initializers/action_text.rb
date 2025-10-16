# class MyActionTextSanitizer < Rails::HTML5::Sanitizer.safe_list_sanitizer
#   class << self
#     def allowed_tags
#       super + %w[div]
#     end
#
#     def allowed_attributes
#       (super + %w[class]).tap do |allowed|
#         Rails.logger.debug "allowed attributes #{allowed.inspect}"
#       end
#     end
#   end
# end
# #
# ActionText::ContentHelper.sanitizer = MyActionTextSanitizer.new
# ActionText::ContentHelper.sanitizer = Rails::HTML5::Sanitizer.safe_list_sanitizer.new

# ActionText::ContentHelper.allowed_tags += %w[div]
#
# ActionText::ContentHelper.allowed_attributes = Rails::HTML4::Sanitizer.safe_list_sanitizer.allowed_attributes + %w[class]
