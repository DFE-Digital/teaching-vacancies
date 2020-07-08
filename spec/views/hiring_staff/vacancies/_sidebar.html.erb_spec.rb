require 'rails_helper'

RSpec.describe 'hiring_staff/vacancies/_sidebar' do
  context 'There are two steps' do
    around do |example|
      # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
      # environment.
      # rubocop:disable Rails/HttpPositionalArguments
      Rails.application.routes.draw do
        get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step for SchoolGroup users only' }
        get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step for all user types' }
      end
      # rubocop:enable Rails/HttpPositionalArguments

      # Without the `without_partial_double_verification` wrapper the `:current_school` stub with fail and raise the
      # exception that the view does not implement `:current_school`.
      without_partial_double_verification { example.run }

      Rails.application.routes_reloader.reload!
    end

    before do
      allow(view).to receive(:params).and_return({ create_step: 1 })
      render
    end

    context 'when the user is a SchoolGroup-level user' do
      before do
        allow(session).to receive(:[]).with(:uid).and_return('1234')
        render
      end

      it 'the correct steps are rendered with correct numbers in correct order' do
        expect(render.gsub("\n", '')).to match(
          /Step.*1.*#{'Step for SchoolGroup users only'}.*Step.*2.*#{'Step for all user types'}/
        )
      end
    end

    context 'when the user is a School-level user' do
      it 'the correct steps are rendered with correct numbers in correct order' do
        expect(render.gsub("\n", '')).to match(/Step.*1.*#{'Step for all user types'}/)
        expect(render.gsub("\n", '')).not_to match(/Step.*2/) end
    end
  end
end
