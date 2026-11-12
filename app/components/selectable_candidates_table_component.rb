# A table of job applications with a checkbox for each candidate, so publishers can select
# candidates and act on them with the form's buttons. The multi-select JavaScript adds a
# "Select all" checkbox. CandidatesTableComponent is the read-only version.
class SelectableCandidatesTableComponent < ApplicationComponent
  include CandidateCells

  def initialize(tab_name:, form_builder:, vacancy:, candidates:, displayed_fields: %i[name email_address status])
    super()
    @tab_name = tab_name
    @form_builder = form_builder
    @vacancy = vacancy
    @candidates = candidates
    @displayed_fields = displayed_fields
  end

  private

  def id_prefix
    "id_all_#{@tab_name}-"
  end

  def checkbox_cell(job_application, index)
    if job_application.unsuccessful? || !job_application.terminal_status?
      tag.div(class: "govuk-checkboxes--small") do
        @form_builder.govuk_check_box(:job_applications, job_application.id,
                                      link_errors: index.zero?,
                                      label: { hidden: true, text: "Select #{job_application.name}" })
      end
    else
      tag.span
    end
  end
end
