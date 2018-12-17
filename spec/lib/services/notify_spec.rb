require 'rails_helper'
require 'services/notify'

RSpec.describe Notify do
  it 'raises a RunTime error if the NOTIFY_KEY is not configured' do
    stub_const('NOTIFY_KEY', nil)
    expect { Notify.new(nil, nil, nil, nil).call }.to raise_error('Notify: NOTIFY_KEY is not set')
  end

  it 'calls Notify\'s send_email service with the correct details ' do
    email_params = { email_address: 'email',
                     template_id: 'template_id',
                     personalisation: {},
                     reference: 'A reference' }

    stub_const('NOTIFY_KEY', 'a key')
    notify = double(:notify)
    expect(Notifications::Client).to receive(:new).with('a key').and_return(notify)
    expect(notify).to receive(:send_email).with(email_params)

    Notify.new('email', {}, 'template_id', 'A reference').call
  end
end
