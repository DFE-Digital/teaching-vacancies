require 'rails_helper'

RSpec.describe 'hiring_staff/vacancies/_sidebar' do
  context 'There are two steps' do
    around do |example|
      # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
      # environment.
      # rubocop:disable Rails/HttpPositionalArguments
      Rails.application.routes.draw do
        get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
        get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
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

    it 'the first step number is displayed' do
      expect(render).to have_css('.app-step-nav__circle--number', text: '1')
    end

    it 'the first step title is displayed' do
      expect(render).to have_css('.js-step-title-text', text: 'Step one')
    end

    it 'the second step number is displayed' do
      expect(render).to have_css('.app-step-nav__circle--number', text: '2')
    end

    it 'the second step title is displayed' do
      expect(render).to have_css('.js-step-title-text', text: 'Step two')
    end
  end
end
