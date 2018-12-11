require 'rails_helper'

RSpec.feature 'A job seeker can subscribe to a job alert' do
  context 'A job seeker' do
    scenario 'can access the new subscription page when search criteria have been specified' do
      expect { visit(new_subscription_path) }.to raise_error(ActionController::ParameterMissing)

      visit new_subscription_path(search_criteria: { some_parameters: 'none' })
      expect(page).to have_content('Sign up for daily emails')
    end

    scenario 'can view the search criteria' do
      visit new_subscription_path(search_criteria: { newly_qualified_teacher: 'true',
                                                     keyword: 'teacher',
                                                     location: 'EC2 9AN',
                                                     radius: '10',
                                                     working_pattern: 'full_time',
                                                     minimum_salary: '20000',
                                                     maximum_salary: '30000' })

      expect(page).to have_content('Keyword: teacher')
      expect(page).to have_content('Suitable for NQTs')
      expect(page).to have_content('Location: Within 10 miles of EC2 9AN')
      expect(page).to have_content('Working pattern: Full time')
      expect(page).to have_content('Minimum salary: £20,000')
      expect(page).to have_content('Maximum salary: £30,000')
    end
  end
end
