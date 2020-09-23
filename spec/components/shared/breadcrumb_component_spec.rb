require 'rails_helper'

RSpec.describe Shared::BreadcrumbComponent, type: :component do
  let(:collapse_on_mobile) { false }
  let(:crumbs) do
    [{ link_text: 'crumb', link_path: '/crumb-path' },
     { link_text: 'you are here', link_path: '/no-link-here' }]
  end

  let!(:inline_component) { render_inline(described_class.new(collapse_on_mobile: collapse_on_mobile, crumbs: crumbs)) }

  context 'when collapse_on_mobile is true' do
    let(:collapse_on_mobile) { true }

    it 'adds the collapse on mobile class' do
      expect(inline_component.css('.govuk-breadcrumbs--collapse-on-mobile')).to_not be_blank
    end
  end

  context 'when collapse_on_mobile is false' do
    it 'does not add the collapse on mobile class' do
      expect(inline_component.css('.govuk-breadcrumbs--collapse-on-mobile')).to be_blank
    end
  end

  it 'renders the breadcrumb link' do
    expect(rendered_component).to include('<a class="govuk-breadcrumbs__link" href="/crumb-path">crumb</a>')
  end

  it 'renders the current page' do
    expect(rendered_component).to include('<span>you are here</span>')
  end
end
