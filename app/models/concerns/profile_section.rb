module ProfileSection
  extend ActiveSupport::Concern

  class_methods do
    def prepare(**, &block)
      find_or_initialize_by(**).tap do |record|
        if record.new_record?
          # do not populate from draft applications as they make be incomplete and invalid.
          if (previously_submitted_application = jobseeker(record).job_applications.after_submission.last)
            copy_attributes(record, previously_submitted_application)

            block&.call(record)
            before_save_on_prepare(record)
          end

          prepare_associations(record)
          complete_steps(record)

          record.save!
        end
      end
    end

    def jobseeker(record)
      record.jobseeker_profile.jobseeker
    end

    def copy_attributes(record, previously_submitted_application)
      attributes_to_copy.each do |attribute|
        record.assign_attributes(attribute => previously_submitted_application.public_send(attribute))
      end
    end

    def attributes_to_copy
      []
    end

    def prepare_associations(_record); end
    def complete_steps(_record); end
    def before_save_on_prepare(_record); end
  end
end
