require 'rails_helper'

RSpec.describe GetSubjectName do
  describe '#get_subject_name' do
    let(:subject) { create(:subject, name: Vacancy::SUBJECT_OPTIONS.sample.first) }
    let(:synonym_subject) { create(:subject, name: described_class::SUBJECT_SYNONYMS.keys.sample) }
    let(:invalid_subject) { create(:subject, name: 'An invalid subject') }

    it 'returns the name for a valid subject' do
      expect(described_class.get_subject_name(subject)).to eql(subject.name)
    end

    it 'returns the synonym name for a subject with a valid synonym' do
      expect(described_class.get_subject_name(synonym_subject)).to eql(
        described_class::SUBJECT_SYNONYMS[synonym_subject.name]
      )
    end

    it 'returns nil for an invalid subject' do
      expect(described_class.get_subject_name(invalid_subject)).to eql(nil)
    end
  end
end
