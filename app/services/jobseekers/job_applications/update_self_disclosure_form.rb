class Jobseekers::JobApplications::UpdateSelfDisclosureForm
  def self.call(...)
    service = new(...)
    return service.result unless service.valid?

    service.update!
    service.result
  end

  attr_reader :form, :model

  def initialize(form, self_disclosure)
    @form = form
    @model = self_disclosure
  end

  def result
    [valid?, form]
  end

  def valid?
    @valid ||= form.valid?
  end

  def update!
    # model.update!(form.attributes)
  end
end
