require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#sanitize' do
    it 'it sanitises the text' do
      html = '<p> a paragraph <a href=\'link\'>with a link</a></p><br>'
      sanitized_html = '<p> a paragraph with a link</p><br>'

      expect(helper.sanitize(html)).to eq(sanitized_html)
    end

    it 'it converts &amp; to &' do
      html = '<p>English  &amp; Drama teacher</p>'
      sanitized_html = '<p>English  & Drama teacher</p>'

      expect(helper.sanitize(html)).to eq(sanitized_html)
    end
  end
end
