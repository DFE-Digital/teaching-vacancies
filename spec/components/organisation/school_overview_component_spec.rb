require 'rails_helper'

RSpec.describe Organisations::SchoolOverviewComponent, type: :component do
  let!(:inline_component) { render_inline(described_class.new(organisation: organisation)) }

  context 'when organisation is a SchoolGroup' do
    let(:organisation) { build(:school_group) }

    it 'does not render the school overview component' do
      expect(rendered_component).to be_blank
    end
  end

  context 'when organisation is a School' do
    let(:organisation) { build(:school) }

    it 'renders the school info heading' do
      expect(inline_component.css('h2.govuk-heading-m').to_html).to include(
        I18n.t('schools.info', organisation: organisation.name)
      )
    end

    it 'renders the school description' do
      expect(rendered_component).to include(organisation.description)
    end

    it 'renders the school address' do
      expect(rendered_component).to include(full_address(organisation))
    end

    it 'renders the school age range' do
      expect(rendered_component).to include(age_range(organisation))
    end

    it 'renders the school type' do
      expect(rendered_component).to include(organisation.school_type.label)
    end

    it 'renders the school website link' do
      expect(inline_component.css("a[href='#{organisation.url}']").to_html).to include(
        I18n.t('schools.website_link_text', school: organisation.name)
      )
    end
  end
end
