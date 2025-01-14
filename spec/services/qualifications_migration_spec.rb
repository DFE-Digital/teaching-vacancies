require 'rails_helper'

RSpec.describe QualificationsMigration, type: :model do
  let!(:qualification) { create(:qualification, category: 'other_secondary') }
  
  before do
    qualification.qualification_results.destroy_all
    QualificationResult.create(qualification: qualification, subject: 'Math', grade: 'A', awarding_body: "AXA")
    QualificationResult.create(qualification: qualification, subject: 'English', grade: 'B', awarding_body: "Bee")
  end

  describe '.perform' do
    it 'migrates qualifications with category other_secondary to other' do
      expect {
        QualificationsMigration.perform
      }.to change { Qualification.where(category: 'other').count }.by(2)
    end

    it 'creates new qualifications with the correct attributes' do
      QualificationsMigration.perform
      new_qualifications = Qualification.where(category: 'other')

      expect(new_qualifications.count).to eq(2)
      expect(new_qualifications.pluck(:subject)).to contain_exactly('Math', 'English')
      expect(new_qualifications.pluck(:grade)).to contain_exactly('A', 'B')
    end

    it 'deletes the original qualification with category other_secondary' do
      expect {
        QualificationsMigration.perform
      }.to change { Qualification.where(category: 'other_secondary').count }.by(-1)
    end

    context 'when an error occurs during migration' do
      before do
        allow(Qualification).to receive(:create!).and_raise(StandardError, 'Test error')
      end

      it 'logs the error and does not delete original qualifications' do
        expect(Rails.logger).to receive(:error).with(/Error migrating qualifications: Test error/)
        expect {
          QualificationsMigration.perform rescue nil
        }.to_not change { Qualification.where(category: 'other_secondary').count }
      end
    end
  end
end
