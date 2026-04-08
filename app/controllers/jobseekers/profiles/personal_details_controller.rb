module Jobseekers::Profiles
  class PersonalDetailsController < Jobseekers::BaseController
    helper_method :escape_path, :back_url

    before_action :set_personal_details_record

    def edit; end

    def update
      if @personal_details_record.update(personal_details_params)
        redirect_to review_jobseekers_profile_personal_details_path
      else
        render "edit"
      end
    end

    private

    def personal_details_params
      params.expect(personal_details: %i[first_name last_name has_right_to_work_in_uk])
    end

    def escape_path
      jobseekers_profile_path
    end

    def set_personal_details_record
      @personal_details_record = current_jobseeker.jobseeker_profile.personal_details || current_jobseeker.jobseeker_profile.build_personal_details
    end
  end
end
