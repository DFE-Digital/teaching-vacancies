module Publishers
  module AtsApi
    module V1
      class UpdateVacancyService
        class << self
          def call(vacancy, params)
            if vacancy.update(permitted_params(params))
              { success: true }
            else
              { success: false, errors: format_errors(vacancy.errors.messages) }
            end
          end

          private

          attr_reader :vacancy, :params

          def permitted_params(params)
            organisations = fetch_organisations(params[:schools])
            raise ActiveRecord::RecordNotFound, "No valid organisations found" if organisations.blank?

            params.except(:schools, :trust_uid).merge(organisations: organisations)
          end

          def fetch_organisations(school_params)
            return [] unless school_params

            if school_params[:trust_uid].present?
              SchoolGroup.trusts.find_by(uid: school_params[:trust_uid]).schools.where(urn: school_params[:school_urns])
            else
              School.where(urn: school_params[:school_urns])
            end
          end

          def format_errors(errors)
            errors.flat_map { |attr, messages| messages.map { |msg| "#{attr}: #{msg}" } }
          end
        end
      end
    end
  end
end
