require 'rails_helper'
RSpec.describe CandidateSpecificationForm, type: :model do
  subject { CandidateSpecificationForm.new({}) }
  let(:feature_enabled?) { false }

  describe 'validations' do
    before { allow(UploadDocumentsFeature).to receive(:enabled?).and_return(feature_enabled?) }

    describe '#education' do
      let(:candidate_specification_form) { CandidateSpecificationForm.new(education: education) }

      context 'when education is blank' do
        let(:education) { nil }

        it 'requests an entry in the field' do
          expect(candidate_specification_form.valid?).to be false
          expect(candidate_specification_form.errors.messages[:education][0])
            .to eq('Enter essential educational requirements')
        end
      end

      context 'when education text is too long' do
        let(:education) { 'short' * 1000 }

        it 'validates the maximum length' do
          expect(candidate_specification_form.valid?).to be false
          expect(candidate_specification_form.errors.messages[:education][0])
            .to eq('Education must not be more than 1000 characters')
        end
      end
    end

    describe '#experience' do
      let(:candidate_specification_form) { CandidateSpecificationForm.new(experience: experience) }

      context 'when experience is blank' do
        let(:experience) { nil }

        it 'requests an entry in the field' do
          expect(candidate_specification_form.valid?).to be false
          expect(candidate_specification_form.errors.messages[:experience][0])
            .to eq('Enter essential skills and experience')
        end
      end

      context 'when experience text is too long' do
        let(:experience) { 'short' * 1000 }

        it 'validates the maximum length' do
          expect(candidate_specification_form.valid?).to be false
          expect(candidate_specification_form.errors.messages[:experience][0])
            .to eq('Skills and experience must not be more than 1000 characters')
        end
      end
    end

    describe '#qualifications' do
      let(:candidate_specification_form) { CandidateSpecificationForm.new(qualifications: qualifications) }

      context 'when qualifications is blank' do
        let(:qualifications) { nil }

        it 'requests an entry in the field' do
          expect(candidate_specification_form.valid?).to be false
          expect(candidate_specification_form.errors.messages[:qualifications][0])
            .to eq('Enter essential qualifications')
        end
      end

      context 'when qualifications text is too long' do
        let(:qualifications) { 'short' * 1000 }

        it 'validates the maximum length' do
          expect(candidate_specification_form.valid?).to be false
          expect(candidate_specification_form.errors.messages[:qualifications][0])
            .to eq('Qualifications must not be more than 1000 characters')
        end
      end
    end
  end
end
