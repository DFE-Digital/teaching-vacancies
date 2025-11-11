require "zip"
require "csv"

class ExportCandidateDataService
  extend JobApplicationsPdfHelper

  Document = Data.define(:filename, :data)

  PII_HEADERS = %w[first_name last_name street_address city postcode phone_number email_address national_insurance_number teacher_reference_number].freeze

  class << self
    def call(job_applications)
      Zip::OutputStream.write_buffer { |zio|
        job_applications.each do |job_application|
          [
            pii_csv(job_application),
            submitted_application_form(job_application),
            references(job_application),
            self_disclosure(job_application),
          ].flatten.each do |document|
            path = [sanitize(job_application.name), document.filename].join("/")
            zio.put_next_entry(path)
            zio.write(document.data)
          end
        end
        zio
      }.tap(&:rewind)
    end

    def sanitize(str)
      str.downcase.tr(" .", "_")
    end

    def pii_csv(job_application)
      data = CSV.generate do |csv|
        csv << PII_HEADERS
        csv << job_application.attributes.slice(*PII_HEADERS).values
      end
      Document["pii.csv", data]
    end

    def references(job_application)
      requests = job_application.referees.filter_map(&:reference_request).select { |req| req.job_reference&.complete? }
      return Document["no_references_found.txt", "No references have been requested through Teaching Vacancies."] if requests.blank?

      requests.map do |request|
        referee_presenter = RefereePresenter.new(request.referee)
        pdf = ReferencePdfGenerator.new(referee_presenter).generate
        Document["references/#{sanitize(request.referee.name)}.pdf", pdf.render]
      end
    end

    def self_disclosure(job_application)
      return Document["no_declarations_found.txt", "No self-disclosure form has been submitted through Teaching Vacancies."] unless job_application.self_disclosure_request&.received?

      self_disclosure = SelfDisclosurePresenter.new(job_application)
      pdf = SelfDisclosurePdfGenerator.new(self_disclosure).generate
      Document["self_disclosure.pdf", pdf.render]
    end
  end
end
