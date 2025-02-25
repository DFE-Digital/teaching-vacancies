module Publishers
  module AtsApi
    class CreateVacancyService
      extend OrganisationFetcher

      class << self
        def call(params)
          vacancy = Vacancy.new(sanitised_params(params))

          if vacancy.valid?
            vacancy.save!
            success_response(vacancy)
          elsif (conflict = vacancy.find_conflicting_vacancy)
            conflict_response(conflict, vacancy.errors[:base].first || vacancy.errors[:external_reference].first)
          else
            validation_error_response(vacancy)
          end
        end

        private

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])

          params[:publish_on] ||= Time.zone.today.to_s
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
