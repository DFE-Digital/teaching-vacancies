module Publishers
  module AtsApi
    class UpdateVacancyService
      extend OrganisationFetcher

      class << self
        def call(vacancy, params)
          vacancy.assign_attributes(sanitised_params(params))

          if vacancy.valid?
            vacancy.save!
            success_response
          elsif (conflict = vacancy.find_conflicting_vacancy)
            conflict_response(conflict, vacancy.errors[:base].first || vacancy.errors[:external_reference].first)
          else
            validation_error_response(vacancy)
          end
        end

        private

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])
          params.except(:schools).merge(organisations: organisations)
        end

        def conflict_response(conflict_vacancy, error_message)
          {
            status: :conflict,
            json: {
              error: error_message,
              link: Rails.application.routes.url_helpers.vacancy_url(conflict_vacancy),
            },
          }
        end

        def success_response
          { success: true }
        end

        def validation_error_response(vacancy)
          {
            success: false,
            errors: vacancy.errors.messages.flat_map do |attr, messages|
              messages.map { |message| "#{attr}: #{message}" }
            end,
          }
        end
      end
    end
  end
end
