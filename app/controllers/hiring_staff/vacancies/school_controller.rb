class HiringStaff::Vacancies::SchoolController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_school_group_user_flag_on
  before_action :redirect_unless_vacancy
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(school_form_params, @vacancy)
  end
  before_action :set_school_options, only: %i[show update]

  def show
    @school_form = SchoolForm.new(@vacancy.attributes)
  end

  def update
    @school_form = SchoolForm.new(school_form_params)

    if @school_form.valid?
      update_vacancy(school_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end

    render :show
  end

  private

  def school_form_params
    params.require(:school_form).permit(:state, :school_id).merge(completed_step: current_step)
  end

  def next_step
    organisation_job_job_specification_path(@vacancy.id)
  end

  def set_school_options
    @school_options = []
    current_school_group.schools.each do |school|
      @school_options.push(SchoolPresenter.new(school))
    end
  end
end
