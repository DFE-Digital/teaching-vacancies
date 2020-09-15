require 'rails_helper'

RSpec.describe NotificationComponent, type: :component do
  let(:content) { 'This is content' }
  let(:style) { 'notice' }
  let(:dismiss) { true }
  let(:background) { false }
  let(:alert) { false }
  let!(:inline_component) { render_inline(NotificationComponent.new(content: content, style: style, dismiss: dismiss, background: background, alert: alert)) }

  context 'when content is a string' do
    it 'renders content in the body' do
      expect(inline_component.css('.govuk-notification__body').to_html).to include(content)
    end
  end

  context 'when content is a hash' do
    let(:content) { { title: 'Title', body: 'This is the body' } }

    it 'renders the title' do
      expect(inline_component.css('.govuk-notification__title').to_html).to include(content[:title])
    end

    it 'renders the body' do
      expect(inline_component.css('.govuk-notification__body').to_html).to include(content[:body])
    end
  end

  context 'when dismiss is true' do
    it 'renders the dismiss link' do
      expect(inline_component.css('.dismiss-link').to_html).to include(I18n.t('buttons.dismiss'))
    end
  end

  context 'when dismiss is false' do
    let(:dismiss) { false }

    it 'does not render the dismiss link' do
      expect(rendered_component).to_not include(I18n.t('buttons.dismiss'))
    end
  end

  context 'when style is notice' do
    it 'applies correct style' do
      expect(inline_component.css('.govuk-notification--notice')).to_not be_blank
    end
  end

  context 'when style is success' do
    let(:style) { 'success' }

    it 'applies correct style' do
      expect(inline_component.css('.govuk-notification--success')).to_not be_blank
    end
  end

  context 'when style is danger' do
    let(:style) { 'danger' }

    it 'does not render the dismiss link' do
      expect(rendered_component).to_not include(I18n.t('buttons.dismiss'))
    end

    it 'applies correct style' do
      expect(inline_component.css('.govuk-notification--danger')).to_not be_blank
    end
  end

  context 'when background is true' do
    let(:background) { true }

    it 'applies the background style' do
      expect(inline_component.css('.govuk-notification__background')).to_not be_blank
    end
  end

  context 'when background is false' do
    it 'does not apply the background style' do
      expect(inline_component.css('.govuk-notification__background')).to be_blank
    end
  end

  context 'when style is success' do
    let(:style) { 'success' }

    it 'does not apply the alert style' do
      expect(inline_component.css('.alert')).to be_blank
    end
  end

  context 'when style is danger' do
    let(:style) { 'danger' }

    it 'does not apply the alert style' do
      expect(inline_component.css('.alert')).to be_blank
    end
  end

  context 'when style is notice' do
    context 'when alert is true' do
      let(:alert) { true }

      it 'applies the alert style' do
        expect(inline_component.css('.alert')).to_not be_blank
      end
    end

    context 'when alert is false' do
      it 'does not apply the alert style' do
        expect(inline_component.css('.alert')).to be_blank
      end
    end
  end
end
