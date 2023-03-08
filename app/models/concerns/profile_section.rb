module ProfileSection
  extend ActiveSupport::Concern

  class_methods do
    def prepare(**init_by)
      find_or_initialize_by(**init_by).tap do |record|
        if record.new_record?
          if (previous_application = jobseeker(record).job_applications.last)
            copy_attributes(record, previous_application)
          end

          prepare_associations(record)
          complete_steps(record)

          before_save_on_prepare(record)
          record.save!
        end
      end
    end

    def jobseeker(record)
      record.jobseeker_profile.jobseeker
    end

    def copy_attributes(record, previous_application)
      attributes_to_copy.each do |attribute|
        record.assign_attributes(attribute => previous_application.public_send(attribute))
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
