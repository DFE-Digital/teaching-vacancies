class Jobseekers::JobApplications::UpdateSelfDisclosureForm
  def self.call(...)
    service = new(...)
    return service.result unless service.valid?

    service.update!
    service.result
  end

  def initialize(form, current_step, steps)
    @form = form
    @current_step = current_step
    @steps = steps
    @form.model.assign_attributes(form.attributes)
  end

  def outcome
    return :done if valid? && last_step?
    return :wizard if valid?

    :error
  end

  def result
    [outcome, @form]
  end

  def valid?
    @valid ||= @form.valid?(@current_step)
  end

  def last_step?
    @steps.last == @current_step
  end

  def update!
    @form.save!(context: @current_step)
  end
end
