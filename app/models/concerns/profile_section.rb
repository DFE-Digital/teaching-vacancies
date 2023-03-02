module ProfileSection
  extend ActiveSupport::Concern

  class_methods do
    def prepare(profile:)
      find_or_initialize_by(jobseeker_profile: profile).tap do |record|
        if record.new_record?
          if (previous_application = profile.jobseeker.job_applications.last)
            attributes_to_copy.each do |attribute|
              record.assign_attributes(attribute => previous_application.public_send(attribute))
            end
          end

          yield record if block_given?

          record.save!
        end
      end
    end

    def attributes_to_copy
      %w[]
    end
  end
end
