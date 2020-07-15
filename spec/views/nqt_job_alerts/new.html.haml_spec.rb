require 'rails_helper'

RSpec.describe 'nqt_job_alerts/new.html.haml' do
  before do
    assign(:nqt_job_alerts_form, NqtJobAlertsForm.new)
  end

  context 'recaptcha' do
    # The recaptcha gem requires that the form element and the checker in the controller both use the same name when
    # using v3.
    it 'inserts a hidden recaptcha form element in the page with the name "subscription"' do
      expect(render).to match(/input type="hidden" name="g-recaptcha-response-data\[subscription\]"/)
    end
  end
end
