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

  it 'updates the original vacancy with the users new preferences' do
    original_vacancy = build(:vacancy)

    new_choices = {
      job_title: 'Foo',
      starts_on: 20.days.from_now.to_date,
      ends_on: 30.days.from_now.to_date,
      expires_on: 5.days.from_now.to_date,
      publish_on: 0.days.from_now.to_date,
    }

    form_object = described_class.new(vacancy: original_vacancy)
                                 .apply_changes(new_choices)

    expect(form_object.job_title).to eq(new_choices[:job_title])
    expect(form_object.starts_on).to eq(new_choices[:starts_on])
    expect(form_object.ends_on).to eq(new_choices[:ends_on])
    expect(form_object.expires_on).to eq(new_choices[:expires_on])
    expect(form_object.publish_on).to eq(new_choices[:publish_on])
  end
end
