class FormFileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # We only want to run the validations in this validator when the form is submitted to check that the file is virus free and the size and
    # type are valid. Every job listing form model's validations are run after a step is completed in all_steps_valid? (see app/form_models/form_sequence.rb:13).
    # At this point the custom validations in this validator do not need to be run.
    return true unless validating_files_after_form_submission?(value)

    @form = record
    @file_upload_field_name = attribute
    @form_field_value = value

    [form_field_value].flatten.each do |file|
      valid_file_size?(file) &&
      valid_file_type?(file) &&
      virus_free?(file)
    end
  end

  private

  attr_reader :form, :file_upload_field_name, :form_field_value

  def validating_files_after_form_submission?(value)
    # If the class of the file attached to the form object is ActionDispatch::Http::UploadedFile, we know that these validations are being run after the submission
    # of the form and not as part of checking if all_steps_valid?. We put the value in an array and then flatten because it (containing the file/files) can be either an array
    # of files or a single file.
    [value].flatten.all?(ActionDispatch::Http::UploadedFile)
  end

  def valid_file_size?(file)
    return true if file.size <= form.file_size_limit

    form.errors.add(
      file_upload_field_name,
      I18n.t(
        "jobs.file_size_error_message",
        filename: file.original_filename,
        size_limit: ActiveSupport::NumberHelper.number_to_human_size(form.file_size_limit),
      ),
    )
    false
  end

  def valid_file_type?(file)
    content_type = MimeMagic.by_magic(file.tempfile)&.type
    return true if form.content_types_allowed.include?(content_type)

    Rails.logger.warn("Attempted to upload '#{file.original_filename}' with forbidden file type '#{content_type}'")
    form.errors.add(file_upload_field_name, I18n.t("jobs.file_type_error_message", filename: file.original_filename, valid_file_types: valid_file_types_for_error_message))
    false
  end

  def virus_free?(file)
    return true if Publishers::DocumentVirusCheck.new(file.tempfile).safe?

    Rails.logger.warn("Attempted to upload '#{file.original_filename}' but Google Drive virus check failed")
    form.errors.add(file_upload_field_name, I18n.t("jobs.file_virus_error_message", filename: file.original_filename))
    false
  end

  def valid_file_types_for_error_message
    form.valid_file_types.to_sentence(two_words_connector: " or ", last_word_connector: " or ")
  end
end