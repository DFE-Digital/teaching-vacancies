# A tab of job applications that publishers can select and act on with the button group.
# Lists that are not acted on in bulk render CandidatesTableComponent directly.
class TabPanelComponent < ApplicationComponent
  def initialize(tab_name:, vacancy:, candidates:, form:, button_group:, displayed_fields: %i[name email_address status])
    super(html_attributes: { class: "tab-#{tab_name}" })
    @tab_name = tab_name
    @vacancy = vacancy
    @candidates = candidates
    @form = form
    @button_group = button_group
    @displayed_fields = displayed_fields
  end
end
