# frozen_string_literal: true

class JobApplicationDecorator < Draper::Decorator
  delegate_all

  def name
    if hide_personal_details?
      anonymised_name
    else
      super
    end
  end

  def anonymised_name
    # create an anoymous ID from the start of the vacancy id and the start of the application id
    vacancy_numbers = vacancy.id.split("-").first.each_char.select { |c| c.ord.between?(48, 57) }.join
    id_numbers = id.split("-").first.each_char.select { |c| c.ord.between?(48, 57) }.join
    "TVS-#{vacancy_numbers}-#{id_numbers}"
  end

  def address
    if hide_personal_details?
      [I18n.t("app.anonymous_applications.not_shown")]
    else
      super
    end
  end

  %i[first_name
     last_name
     previous_names
     street_address
     postcode
     city
     country
     national_insurance_number
     phone_number
     email_address
     teacher_reference_number].each do |attribute|
    define_method attribute do
      value = super()
      if value.present? && hide_personal_details?
        I18n.t("app.anonymous_applications.not_shown")
      else
        value
      end
    end
  end
end
