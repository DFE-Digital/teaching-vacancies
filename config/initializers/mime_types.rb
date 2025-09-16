# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Add support for all supported application form file types
# Define at `Vacancy::DOCUMENT_CONTENT_TYPES`
# %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze
Mime::Type.register "application/zip", :zip, [], %w[zip]
Mime::Type.register "application/msword", :doc, [], %w[doc]
Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx, [], %w[docx]
