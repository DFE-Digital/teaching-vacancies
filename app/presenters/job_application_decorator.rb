# frozen_string_literal: true

class JobApplicationDecorator < Draper::Decorator
  delegate_all

  Document = Data.define(:filename, :data)

  def submitted_application_form
    if vacancy.uploaded_form?
      return Document["no_application_form.txt", "the candidate has no application for on record"] unless application_form.attached?

      extension = File.extname(application_form.filename.to_s)
      Document["application_form#{extension}", application_form.download]
    else
      pdf = JobApplicationPdfGenerator.new(self).generate
      Document["application_form.pdf", pdf.render]
    end
  end

  def name
    if hide_personal_details?
      # create an anoymous ID from the start of the vacancy id and the start of the application id
      vacancy_numbers = vacancy.id.split("-").first.each_char.select { |c| c.ord.between?(48, 57) }.join
      id_numbers = id.split("-").first.each_char.select { |c| c.ord.between?(48, 57) }.join
      "TVS-#{vacancy_numbers}-#{id_numbers}"
    else
      super
    end
  end

  def first_name
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def last_name
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def previous_names
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def street_address
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def postcode
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def city
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def country
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def national_insurance_number
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def phone_number
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def email_address
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end

  def teacher_reference_number
    if hide_personal_details?
      I18n.t("app.anonymous_applications.not_shown")
    else
      super
    end
  end
end
