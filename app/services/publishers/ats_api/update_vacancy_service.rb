module Publishers
  module AtsApi
    class UpdateVacancyService
      extend OrganisationFetcher

      class << self
        def call(vacancy, params)
          vacancy.assign_attributes(sanitised_params(params))

          if vacancy.valid?
            vacancy.save!
            { status: :ok }
          elsif (conflict = vacancy.find_conflicting_vacancy)
            conflict_response(conflict, vacancy.errors[:base].first || vacancy.errors[:external_reference].first)
          else
            validation_error_response(vacancy)
          end
        end

        private

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])
          ect_status = ect_status_from(params[:ect_suitable])
          params[:ect_status] = ect_status if ect_status.present?
          params.except(:schools, :ect_suitable).merge(organisations: organisations)
        end

        # On the update, does not change the already set value unless it is explicitly set to true/false.
        def ect_status_from(ect_suitable)
          case ect_suitable
          when true, "true" then "ect_suitable"
          when false, "false" then "ect_unsuitable"
          end
        end

        def conflict_response(conflict_vacancy, error_message)
          {
            status: :conflict,
            json: {
              errors: [error_message],
              meta: {
                link: Rails.application.routes.url_helpers.vacancy_url(conflict_vacancy),
              },
            },
          }
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
