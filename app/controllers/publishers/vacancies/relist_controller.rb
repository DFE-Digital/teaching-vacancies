class Publishers::Vacancies::RelistController < Publishers::Vacancies::WizardBaseController
  include Publishers::VacancyCopy

  def create
    @vacancy = copy_vacancy(vacancy)

    @form = Publishers::JobListing::RelistForm.new

    render :edit
  end

  def update
    @form = Publishers::JobListing::RelistForm.new(relist_params)
    if @form.valid?
      vacancy.update(@form.attributes_to_save.merge(type: "PublishedVacancy"))
      trigger_publisher_vacancy_relisted_event
      update_google_index(vacancy)
      redirect_to organisation_job_summary_path(vacancy.id), success: t(".success", job_title: vacancy.job_title)
    else
      @vacancy = vacancy
      render :edit
    end
  end

  private

  def relist_params
    params.expect(publishers_job_listing_relist_form: %i[expires_at expiry_time publish_on publish_on_day extension_reason other_extension_reason_details])
  end

  def trigger_publisher_vacancy_relisted_event
    fail_safe do
      event_data = {
        data: {
          relist_form: @form.attributes_to_save,
        },
      }

      event = DfE::Analytics::Event.new
                                   .with_type(:publisher_vacancy_relisted)
                                   .with_request_details(request)
                                   .with_response_details(response)
                                   .with_user(current_publisher)
                                   .with_data(event_data)

      DfE::Analytics::SendEvents.do([event])
    end
  end
end
