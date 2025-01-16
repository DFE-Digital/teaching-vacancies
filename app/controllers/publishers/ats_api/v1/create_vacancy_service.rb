module Publishers
  module AtsApi
    module V1
      class CreateVacancyService
        InvalidOrganisationError = Class.new(StandardError)

        class << self
          def call(params)
            vacancy = Vacancy.new(sanitised_params(params))

            if (conflict = conflict_vacancy(vacancy))
              return conflict_response(conflict)
            end

            if vacancy.save
              success_response(vacancy)
            else
              validation_error_response(vacancy)
            end
          end

          private

          def sanitised_params(params)
            organisations = fetch_organisations(params[:schools])
            raise InvalidOrganisationError, "No valid organisations found" if organisations.blank?

            params[:publish_on] ||= Time.zone.today.to_s
            params[:working_patterns] ||= []
            params[:phases] ||= []

            params.except(:schools, :trust_uid).merge(organisations: organisations)
          end

          def fetch_organisations(school_params)
            return [] unless school_params

            if school_params[:trust_uid].present?
              SchoolGroup.trusts.find_by(uid: school_params[:trust_uid])&.schools&.where(urn: school_params[:school_urns]) || []
            else
              School.where(urn: school_params[:school_urns])
            end
          end

          def conflict_vacancy(vacancy)
            Vacancy.find_by(external_reference: vacancy.external_reference)
          end

          def conflict_response(conflict_vacancy)
            {
              status: :conflict,
              json: {
                error: "A vacancy with the provided external reference already exists",
                link: Rails.application.routes.url_helpers.vacancy_url(conflict_vacancy),
              },
            }
          end

          def success_response(vacancy)
            { status: :created, json: { id: vacancy.id } }
          end

          def validation_error_response(vacancy)
            {
              status: :unprocessable_entity,
              json: {
                errors: vacancy.errors.messages.flat_map do |attr, messages|
                  messages.map { |message| "#{attr}: #{message}" }
                end,
              },
            }
          end
        end
      end
    end
  end
end
