require 'rails_helper'

RSpec.describe Jobseekers::StartPageFiltersComponent, type: :component do
  let(:form) do
    form_for VacancyAlgoliaSearchForm.new, as: 'jobs_search_form', url: '/jobs', html: { method: 'get' }
  end

  before { render_inline(described_class.new(form: form)) }

  it 'has no accordion foldy foldies' do
    expect(rendered_component).not_to be_blank
  end
end
