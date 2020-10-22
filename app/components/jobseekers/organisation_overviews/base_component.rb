class Jobseekers::OrganisationOverviews::BaseComponent < ViewComponent::Base
  include OrganisationHelper
  include VacanciesHelper

  attr_accessor :organisation, :vacancy

  def initialize(vacancy:)
    @vacancy = vacancy
    @organisation = vacancy.parent_organisation
  end

  def organisation_map_data
    { name: organisation&.name, lat: organisation.geolocation&.x, lng: organisation.geolocation&.y }.to_json
  end

  def organisation_rows
    [{ present: organisation.group_type != 'local_authority', th: I18n.t('school_groups.type'), td: organisation.group_type },
     { present: organisation.website.present? || organisation.url.present?,
       th: I18n.t('school_groups.website', organisation_type: organisation_type_basic(organisation).humanize),
       td: link_to(I18n.t('schools.website_link_text', organisation_name: organisation.name),
                   organisation.website.presence || organisation.url,
                   class: 'govuk-link link-wrap', target: '_blank') }]
  end

  def school_rows(school)
    [{ present: true, th: I18n.t('schools.type'), td: organisation_type(organisation: school, with_age_range: false) },
     { present: true, th: I18n.t('schools.phase'), td: school_phase(school) },
     { present: true, th: I18n.t('schools.school_size'), td: school_size(school) },
     { present: true, th: I18n.t('schools.age_range'), td: age_range(school) },
     { present: ofsted_report(school).present?,
       th: I18n.t('schools.ofsted_report'),
       td: link_to(I18n.t('schools.view_ofsted_report'), ofsted_report(school), class: 'govuk-link wordwrap',
                                                                                target: '_blank'),
       blank: I18n.t('schools.no_information') },
     { present: school.website.present? || school.url.present?,
       th: I18n.t('schools.website'),
       td: link_to(I18n.t('schools.website_link_text', organisation_name: school.name),
                   school.website.presence || school.url, class: 'govuk-link link-wrap', target: '_blank') }]
  end

  def vacancy_rows
    [{ present: vacancy.contact_email.present?,
       th: I18n.t('jobs.contact_email'),
       td: mail_to(vacancy.contact_email, vacancy.contact_email, class: 'govuk-link link-wrap',
                                                                 subject: I18n.t('jobs.contact_email_subject', job: vacancy.job_title),
                                                                 body: I18n.t('jobs.contact_email_body', url: job_url(vacancy))) },
     { present: vacancy.contact_number.present?,
       th: I18n.t('jobs.contact_number'),
       td: link_to(vacancy.contact_number, "tel:#{vacancy.contact_number}", class: 'govuk-link') }]
  end
end
