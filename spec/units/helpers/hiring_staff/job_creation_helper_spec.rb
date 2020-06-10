require 'rails_helper'

RSpec.describe HiringStaff::JobCreationHelper do
  describe '#current_step' do
    let(:params) do
      double('params')
    end

    it 'returns the value of the `create_step` param' do
      allow(params).to receive(:[]).with(:create_step).and_return(1)
      allow(helper).to receive(:params).and_return(params)
      expect(helper.current_step).to eql(1)
    end
  end

  describe '#steps_to_display' do
    context 'steps are correctly ordered in `routes.rb`' do
      around do |example|
        # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
        # environment.
        # rubocop:disable Rails/HttpPositionalArguments
        Rails.application.routes.draw do
          get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
        end
        # rubocop:enable Rails/HttpPositionalArguments

        example.run

        Rails.application.routes_reloader.reload!
      end

      it 'returns an array of arrays with the step number and step title to be displayed' do
        expect(helper.steps_to_display).to eql([
          { number: 1, title: 'Step one' },
          { number: 2, title: 'Step two' }
        ])
      end
    end

    context 'steps are not ordered in `routes.rb`' do
      around do |example|
        # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
        # environment.
        # rubocop:disable Rails/HttpPositionalArguments
        Rails.application.routes.draw do
          get :step_three, to: 'job#step_three', defaults: { create_step: 3, step_title: 'Step three' }
          get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
        end
        # rubocop:enable Rails/HttpPositionalArguments

        example.run

        Rails.application.routes_reloader.reload!
      end

      it 'returns an array of arrays with the step number and step title to be displayed' do
        expect(helper.steps_to_display).to eql([
          { number: 1, title: 'Step one' },
          { number: 2, title: 'Step two' },
          { number: 3, title: 'Step three' }
        ])
      end
    end

    context 'multiple routes are part of the same step' do
      around do |example|
        # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
        # environment.
        # rubocop:disable Rails/HttpPositionalArguments
        Rails.application.routes.draw do
          get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_one_a, to: 'job#step_one_a', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
        end
        # rubocop:enable Rails/HttpPositionalArguments

        example.run

        Rails.application.routes_reloader.reload!
      end

      it 'returns an array of arrays with the step number and step title to be displayed' do
        expect(helper.steps_to_display).to eql([
          { number: 1, title: 'Step one' },
          { number: 2, title: 'Step two' }
        ])
      end
    end
  end

  describe '#total_steps' do
    context 'all steps are unique' do
      around do |example|
        # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
        # environment.
        # rubocop:disable Rails/HttpPositionalArguments
        Rails.application.routes.draw do
          get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
        end
        # rubocop:enable Rails/HttpPositionalArguments

        example.run

        Rails.application.routes_reloader.reload!
      end

      it 'counts the correct number of steps' do
        expect(helper.total_steps).to eql(2)
      end
    end

    context 'multiple routes are part of the same step' do
      around do |example|
        # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
        # environment.
        # rubocop:disable Rails/HttpPositionalArguments
        Rails.application.routes.draw do
          get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_one_a, to: 'job#step_one_a', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
        end
        # rubocop:enable Rails/HttpPositionalArguments

        example.run

        Rails.application.routes_reloader.reload!
      end

      it 'counts the correct number of unique steps' do
        expect(helper.total_steps).to eql(2)
      end
    end
  end

  describe '#set_visited_step_class' do
    let(:vacancy) { instance_double('Vacancy') }

    context 'when subsequent steps have been completed' do
      around do |example|
        # Rubocop mistakes the verb-based route definitions for the identically named commands used to interact with
        # environment.
        # rubocop:disable Rails/HttpPositionalArguments
        Rails.application.routes.draw do
          get :step_one, to: 'job#step_one', defaults: { create_step: 1, step_title: 'Step one' }
          get :step_two, to: 'job#step_two', defaults: { create_step: 2, step_title: 'Step two' }
          get :step_three, to: 'job#step_three', defaults: { create_step: 3, step_title: 'Step three' }
        end
        # rubocop:enable Rails/HttpPositionalArguments

        example.run

        Rails.application.routes_reloader.reload!
      end

      it 'returns the visited class for step 1, active class for step 2, visited class for step 3' do
        allow(params).to receive(:[]).with(:create_step).and_return(2)
        allow(vacancy).to receive_message_chain(:completed_step, :present?).and_return(true)
        allow(vacancy).to receive(:completed_step).and_return(3)

        expect(helper.set_visited_step_class(1, vacancy)).to eql('app-step-nav__step--visited')
        expect(helper.set_active_step_class(2)).to eql('app-step-nav__step--active')
        expect(helper.set_visited_step_class(2, vacancy)).to eql(nil)
        expect(helper.set_visited_step_class(3, vacancy)).to eql('app-step-nav__step--visited')
      end
    end
  end
end
