require 'rails_helper'

RSpec.describe UpdatesController, type: :controller do
  let(:date) { Date.new(2020, 04, 10) }
  let(:update_paths) do
    [
      'path/noHtmlOrDateFile',
      'path/no_leading_underscore_or_date.html.erb',
      'path/_update_title_no_date.html.erb',
      'path/_update_title_2020_400_100.html.erb',
      'path/_2020_400_100.html.erb',
      'path/_2020_04_10.html.erb',
      'path/_valid_update_title_2020_04_10.html.erb'
    ]
  end

  describe '#update_file_paths_to_hash' do
    it 'only adds valid update files to the hash' do
      expect(subject.update_file_paths_to_hash(update_paths)[date])
        .to eql([{ path: 'valid_update_title_2020_04_10', name: 'Valid update title' }])
    end
  end
end
