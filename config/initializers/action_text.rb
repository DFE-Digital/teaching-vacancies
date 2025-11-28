# The default is Rails::HTML5::Sanitizer but that seems to only allow a very small subset of HTML tags
# and attrs - specifically no divs and no class attributes.
Rails.application.config.after_initialize do
  ActionText::ContentHelper.sanitizer = Rails::HTML4::Sanitizer.safe_list_sanitizer.new
end
