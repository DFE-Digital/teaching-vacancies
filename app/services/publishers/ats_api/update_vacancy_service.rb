module Publishers
  module AtsApi
    class UpdateVacancyService
      extend OrganisationFetcher

      class << self
        def call(vacancy, params)
          if vacancy.update(sanitised_params(params))
            { success: true }
          else
            { success: false, errors: format_errors(vacancy.errors.messages) }
          end
        end

        private

        attr_reader :vacancy, :params

        def sanitised_params(params)
          organisations = fetch_organisations(params[:schools])
          raise ActiveRecord::RecordNotFound, "No valid organisations found" if organisations.blank?

          params.except(:schools).merge(organisations: organisations)
        end

        def format_errors(errors)
          errors.flat_map { |attr, messages| messages.map { |msg| "#{attr}: #{msg}" } }
        end
      end
    end
  end
end
