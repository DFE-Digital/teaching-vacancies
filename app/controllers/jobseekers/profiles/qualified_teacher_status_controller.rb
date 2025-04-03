module Jobseekers
  module Profiles
    class QualifiedTeacherStatusController < Jobseekers::ProfilesController
      def edit
        @form = QualifiedTeacherStatusForm.new(profile.slice(*form_class.fields))
      end

      def update
        @form = QualifiedTeacherStatusForm.new(form_params)
        if @form.valid?
          profile.update!(@form.params_to_save)
          redirect_to jobseekers_profile_qualified_teacher_status_path
        else
          render :edit
        end
      end

      private

      def form_class
        QualifiedTeacherStatusForm
      end

      def form_params
        params.require(:jobseekers_profiles_qualified_teacher_status_form).permit(form_class.fields)
      end
    end
  end
end
