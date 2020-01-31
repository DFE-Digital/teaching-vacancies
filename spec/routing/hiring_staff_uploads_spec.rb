require 'rails_helper'

RSpec.describe 'Hiring staff document upload routing' do
  it {
    expect(get: '/school/job/documents').to route_to(
      controller: 'hiring_staff/vacancies/documents',
      action: 'index',
    )
  }
end
