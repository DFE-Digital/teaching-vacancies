# A candidates table with a checkbox for each candidate, so publishers can select candidates and
# act on them with the form's buttons. The multi-select JavaScript adds a "Select all" checkbox.
class SelectableCandidatesTableComponent < CandidatesTableComponent
  def initialize(tab_name:, form_builder:, **)
    super(**)
    @tab_name = tab_name
    @form_builder = form_builder
  end

  private

  def table_args
    { html_attributes: { data: { controller: "multi-select", id_prefix: } } }
  end

  def header_cells
    [{ html_attributes: { id: "#{id_prefix}select-all" } }, *super]
  end

  def row_cells(job_application, index)
    [{ text: checkbox_cell(job_application, index) }, *super]
  end

  def id_prefix
    "id_all_#{@tab_name}-"
  end

  # Applications in a terminal status can't move on, so there is nothing to select them for
  def checkbox_cell(job_application, index)
    return tag.span if job_application.terminal_status?

    tag.div(class: "govuk-checkboxes--small") do
      @form_builder.govuk_check_box(:job_applications, job_application.id,
                                    link_errors: index.zero?,
                                    label: { hidden: true, text: "Select #{job_application.name}" })
    end
  end
end
