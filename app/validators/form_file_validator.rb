# TODO - this whole class could be replaced with https://github.com/igorkasyanchuk/active_storage_validations
# Possibly this could happen when we move over to Azure storage, which will do the virus check for us rather than the
# upload/download from google cloud as we currently have it.
class FormFileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # We only want to run the validations in this validator when the form is submitted to check that the file is virus free and the size and
    # type are valid. Every job listing form model's validations are run after a step is completed in all_steps_valid?
    # (see app/form_models/form_sequence.rb:13). At this point the custom validations in this validator do not need to be run.
    if validating_files_after_form_submission?(value)
      [value].flatten.each do |file|
        valid_file_size?(record, attribute, file) &&
          valid_file_type?(record, attribute, file) &&
          virus_free?(record, attribute, file)
      end
    end
  end

  private

  def validating_files_after_form_submission?(value)
    # If the class of the file attached to the form object is ActionDispatch::Http::UploadedFile, we know that these validations are being run after the submission
    # of the form and not as part of checking if all_steps_valid?. We put the value in an array and then flatten because it (containing the file/files) can be either an array
    # of files or a single file.
    [value].flatten.all?(ActionDispatch::Http::UploadedFile)
  end

  def valid_file_size?(record, attribute, value)
    return true if value.size <= options[:file_size_limit]

    record.errors.add(
      attribute,
      I18n.t(
        "jobs.file_size_error_message",
        filename: value.original_filename,
        size_limit: ActiveSupport::NumberHelper.number_to_human_size(options[:file_size_limit]),
      ),
    )
    false
  end

  def valid_file_type?(record, attribute, value)
    content_type = MimeMagic.by_magic(value.tempfile)&.type
    return true if options[:content_types_allowed].include?(content_type)

    Rails.logger.warn("Attempted to upload '#{value.original_filename}' with forbidden file type '#{content_type}'")
    record.errors.add(attribute, I18n.t("jobs.file_type_error_message", filename: value.original_filename, valid_file_types: valid_file_types_for_error_message))
    false
  end

  def virus_free?(record, attribute, value)
    return true if Publishers::DocumentVirusCheck.new(value.tempfile).safe?

    Rails.logger.warn("Attempted to upload '#{value.original_filename}' but Google Drive virus check failed")
    record.errors.add(attribute, I18n.t("jobs.file_virus_error_message", filename: value.original_filename))
    false
  end

  def valid_file_types_for_error_message
    options[:valid_file_types].to_sentence(two_words_connector: " or ", last_word_connector: " or ")
  end
end
