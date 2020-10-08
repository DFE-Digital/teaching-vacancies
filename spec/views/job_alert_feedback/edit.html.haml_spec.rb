require 'rails_helper'

RSpec.describe 'job_alert_feedback/edit.html.haml' do
  before do
    assign(:feedback_form, JobAlertFeedbackForm.new)
    allow(view).to receive(:subscription_feedback_path).and_return('/stubbed-path')
  end

  context 'recaptcha' do
    # The recaptcha gem requires that the form element and the checker in the controller both use the same name when
    # using v3.
    it 'inserts a hidden recaptcha form element in the page with the name "job_alert_feedback"' do
      expect(render).to match(/input type="hidden" name="g-recaptcha-response-data\[job_alert_feedback\]"/)
    end
  end
end
