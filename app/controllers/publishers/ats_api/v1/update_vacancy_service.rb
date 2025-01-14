module Publishers
  module AtsApi
    module V1
      class UpdateVacancyService
        def initialize(vacancy, params)
          @vacancy = vacancy
          @params = params
        end

        def call
          if vacancy.update(permitted_params)
            success_response
          else
            validation_error_response
          end
        end

        private

        attr_reader :vacancy, :params

        def permitted_params
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

        def success_response
          {
            status: :ok,
            json: Publishers::AtsApi::V1::VacancySerialiser.new(vacancy: vacancy).call,
          }
        end

        def validation_error_response
          {
            status: :unprocessable_entity,
            json: {
              errors: vacancy.errors.messages.flat_map do |attribute, messages|
                messages.map { |message| { error: "#{attribute}: #{message}" } }
              end,
            },
          }
        end
      end
    end
  end
end
