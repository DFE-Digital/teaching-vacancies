require 'rails_helper'

RSpec.describe Shared::BannerLinkComponent, type: :component do
  let(:icon_class) { 'icon-class' }
  let(:link_path) { '/link-to-nowhere' }
  let(:link_text) { 'Click this link!' }

  before do
    render_inline(described_class.new(
                    icon_class: icon_class,
                    link_method: link_method,
                    link_path: link_path,
                    link_text: link_text,
                  ))
  end

  context 'when link_method is :get' do
    let(:link_method) { :get }

    it 'renders the banner link' do
      expect(rendered_component).to eql(
        '<a class="banner-link banner-link--icon-class" data-method="get" href="/link-to-nowhere">'\
        '<div class="banner-link__text">Click this link!</div></a>',
      )
    end
  end

  context 'when link_method is :post' do
    let(:link_method) { :post }

    it 'renders the banner link' do
      expect(rendered_component).to eql(
        '<a class="banner-link banner-link--icon-class" rel="nofollow" data-method="post" href="/link-to-nowhere">'\
        '<div class="banner-link__text">Click this link!</div></a>',
      )
    end
  end
end
