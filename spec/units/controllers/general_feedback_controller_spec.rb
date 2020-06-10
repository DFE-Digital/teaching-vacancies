require 'rails_helper'

RSpec.describe GeneralFeedbackController, type: :controller do
  describe '#create' do
    let(:feedback) do
      instance_double(GeneralFeedback).as_null_object
    end

    context 'verify_recaptcha is true and @feeback.valid? is true' do
      before do
        allow(GeneralFeedback).to receive(:new).and_return(feedback)
        allow(feedback).to receive(:valid?).and_return(true)
        allow(controller).to receive(:recaptcha_reply).and_return({ 'score' => 0.9 })
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      it 'verifies the recaptcha' do
        expect(controller).to receive(:verify_recaptcha)
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
      end

      it 'sends the GeneralFeedback instance and action (both required) when it verifies the recaptcha' do
        expect(controller).to receive(:verify_recaptcha).with(model: feedback, action: 'feedback')
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
      end

      it 'sets the recaptcha score on the GeneralFeedback record' do
        expect(feedback).to receive(:recaptcha_score=).with(0.9)
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
      end

      it 'saves the GeneralFeedback record' do
        expect(feedback).to receive(:save)
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
      end

      it 'redirects to root' do
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
        expect(response).to redirect_to(root_url)
      end
    end

    context 'verify_recaptcha is false and @feeback.valid? is true' do
      before do
        allow(GeneralFeedback).to receive(:new).and_return(feedback)
        allow(feedback).to receive(:valid?).and_return(true)
        allow(controller).to receive(:verify_recaptcha).and_return(false)
      end

      it 'does not set the recaptcha score on the GeneralFeedback record' do
        expect(feedback).not_to receive(:recaptcha_score=)
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
      end

      it 'saves the GeneralFeedback record' do
        expect(feedback).to receive(:save)
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
      end

      it 'redirects to root' do
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
        expect(response).to redirect_to(root_url)
      end
    end

    context 'verify_recaptcha is anything and @feeback.valid? is false' do
      before do
        allow(GeneralFeedback).to receive(:new).and_return(feedback)
        allow(feedback).to receive(:valid?).and_return(false)
      end

      it 'renders :new' do
        post :create, params: { general_feedback: attributes_for(:general_feedback) }
        expect(response).to render_template(:new)
      end
    end
  end
end
