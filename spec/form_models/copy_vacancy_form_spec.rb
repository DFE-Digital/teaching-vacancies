require 'rails_helper'

RSpec.describe CopyVacancyForm, type: :model do
  it 'copies the vacancy attributes to the form object' do
    original_vacancy = build(:vacancy)

    form_object = described_class.new(vacancy: original_vacancy)

    expect(form_object.job_title).to eq(original_vacancy.job_title)
    expect(form_object.starts_on).to eq(original_vacancy.starts_on)
    expect(form_object.ends_on).to eq(original_vacancy.ends_on)
    expect(form_object.expires_on).to eq(original_vacancy.expires_on)
    expect(form_object.publish_on).to eq(original_vacancy.publish_on)
  end

  it 'doesn’t copy the expiry date for expired vacancies' do
    expired_vacancy = build(:vacancy, :expired)
    form_object = described_class.new(vacancy: expired_vacancy)
    expect(form_object.expires_on).to be_nil
  end

  describe '#apply_changes!' do
    it 'updates the original vacancy with the users new preferences' do
      original_vacancy = build(:vacancy)

      new_choices = {
        job_title: 'Foo',
        starts_on: 20.days.from_now.to_date,
        ends_on: 30.days.from_now.to_date,
        expires_on: 5.days.from_now.to_date,
        publish_on: 0.days.from_now.to_date,
      }

      new_vacancy = described_class.new(vacancy: original_vacancy)
                                   .apply_changes!(new_choices)

      expect(new_vacancy).to be_kind_of(Vacancy)
      expect(new_vacancy.job_title).to eq(new_choices[:job_title])
      expect(new_vacancy.starts_on).to eq(new_choices[:starts_on])
      expect(new_vacancy.ends_on).to eq(new_choices[:ends_on])
      expect(new_vacancy.expires_on).to eq(new_choices[:expires_on])
      expect(new_vacancy.publish_on).to eq(new_choices[:publish_on])
    end

    it 'does not make changes to the form_object so the form can be repopulated on error' do
      original_vacancy = build(:vacancy)

      new_choices = {
        job_title: 'Foo',
        starts_on: 20.days.from_now.to_date,
        ends_on: 30.days.from_now.to_date,
        expires_on: 5.days.from_now.to_date,
        publish_on: 0.days.from_now.to_date,
      }

      form_object = described_class.new(vacancy: original_vacancy)
      form_object.apply_changes!(new_choices)

      expect(form_object.job_title).to eq(new_choices[:job_title])
      expect(form_object.starts_on).to eq(new_choices[:starts_on])
      expect(form_object.ends_on).to eq(new_choices[:ends_on])
      expect(form_object.expires_on).to eq(new_choices[:expires_on])
      expect(form_object.publish_on).to eq(new_choices[:publish_on])
    end
  end
end
