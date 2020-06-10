require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::ApplicationController, type: :controller do
  describe '#update_google_index' do
    let!(:vacancy) { create(:vacancy) }

    context 'when in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'does perform the task' do
        expect(UpdateGoogleIndexQueueJob).to receive(:perform_later)
        controller.update_google_index(vacancy)
      end
    end

    context 'when NOT in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'does NOT perform the task' do
        expect(UpdateGoogleIndexQueueJob).not_to receive(:perform_later)
        controller.update_google_index(vacancy)
      end
    end
  end

  describe '#remove_google_index' do
    let!(:vacancy) { create(:vacancy) }

    context 'when in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'does perform the task' do
        expect(RemoveGoogleIndexQueueJob).to receive(:perform_later)
        controller.remove_google_index(vacancy)
      end
    end

    context 'when NOT in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'does NOT perform the task' do
        expect(RemoveGoogleIndexQueueJob).not_to receive(:perform_later)
        controller.remove_google_index(vacancy)
      end
    end
  end

  describe '#strip_empty_checkboxes' do
    let(:params) do
      { test_form: { test_field: checkboxes } }
    end

    before do
      allow(controller).to receive(:params).and_return(params)
    end

    context 'no empty checkboxes added by GOVUKDesignSystemFormBuilder' do
      let(:checkboxes) { ['first_box', 'second_box'] }

      it 'removes nothing from the array' do
        subject.strip_empty_checkboxes(:test_form, [:test_field])
        expect(controller.params[:test_form][:test_field]).to eql(checkboxes)
      end
    end

    context 'empty checkbox added by GOVUKDesignSystemFormBuilder' do
      let(:checkboxes) { ['first_box', 'second_box', ''] }
      let(:stripped_checkboxes) { ['first_box', 'second_box'] }

      it 'removes empty checkbox from the array' do
        subject.strip_empty_checkboxes(:test_form, [:test_field])
        expect(controller.params[:test_form][:test_field]).to eql(stripped_checkboxes)
      end
    end
  end

  describe '#convert_multiparameter_attributes_to_dates' do
    let(:params) do
      { test_form: dates }
    end

    before do
      allow(controller).to receive(:params).and_return(params)
    end

    context 'date present in params' do
      let(:dates) { { 'starts_on(3i)': '01', 'starts_on(2i)': '01', 'starts_on(1i)': '2020' } }

      it 'converts date params to a Date object' do
        subject.convert_multiparameter_attributes_to_dates(:test_form, [:starts_on])
        expect(controller.params[:test_form][:starts_on]).to eql(Date.new(2020, 01, 01))
      end
    end

    context 'invalid date in params' do
      let(:dates) { { 'starts_on(3i)': '100', 'starts_on(2i)': '', 'starts_on(1i)': '2020' } }

      it 'the form object has an invalid date error' do
        expect(subject.convert_multiparameter_attributes_to_dates(:test_form, [:starts_on])[:starts_on]).to eql(
          I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.invalid')
        )
      end

      it 'does not convert date params to a Date object' do
        expect(controller.params[:test_form][:starts_on]).to eql(nil)
      end
    end

    context 'date not present in params' do
      let(:dates) { { 'starts_on(3i)': '', 'starts_on(2i)': '', 'starts_on(1i)': '' } }

      it 'does not convert date params to a Date object' do
        subject.convert_multiparameter_attributes_to_dates(:test_form, [:starts_on])
        expect(controller.params[:test_form][:starts_on]).to eql(nil)
      end
    end
  end
end
