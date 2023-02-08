module Multistep
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :back_url, :escape_path
    end

    def start
      @form = self.class.multistep_form.new
      store_form!

      redirect_to action: :edit, step: all_steps.first
    end

    def edit
      @step = form.steps[current_step]
      render params[:step]
    end

    def update
      @step = form.steps[current_step]
      # TODO: Move strong params inside the form implementation
      @step.assign_attributes(params[self.class.multistep_form_key].to_unsafe_hash || {})

      if @step.valid?
        form.complete_step! current_step
        completed_hook = self.class.completed_hooks[current_step]
        instance_exec(form, &completed_hook) if completed_hook
        store_form!
        return if performed?

        if (next_step = form.next_step(current_step: current_step))
          redirect_to action: :edit, step: next_step
        else
          complete
        end
      else
        render current_step, status: :unprocessable_entity
      end
    end

    private

    def current_step
      return @current_step if defined?(@current_step)

      params[:step].to_sym if params.key?(:step)
    end

    def escape_path
      return @escape_path if defined?(@escape_path)

      instance_exec(&self.class.escape_path)
    end

    def form
      @form ||= self.class.multistep_form.new(attributes_from_store)
    end

    # TODO: Convert store handling into a proper object!
    def store_form!
      session[:form] = form.attributes
    end

    def attributes_from_store
      session[:form] || {}
    end

    def all_steps
      @all_steps ||= self.class.multistep_form.steps.keys
    end

    def back_url
      previous_step = form.previous_step(current_step: current_step)
      return escape_path if previous_step.nil?

      url_for action: :edit, step: previous_step
    end

    def complete
      redirect_to escape_path
    end

    class_methods do
      attr_reader :multistep_form_key, :escape_path

      def multistep_form(form = nil, key: nil)
        if form.nil?
          @multistep_form
        else
          @multistep_form = form
          @multistep_form_key = key
        end
      end

      def escape_path(&block)
        return @escape_path unless block

        @escape_path ||= block
      end

      def on_completed(step, &block)
        completed_hooks[step] = block
      end

      def completed_hooks
        @completed_hooks ||= {}
      end
    end
  end
end
