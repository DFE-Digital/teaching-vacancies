module Publishers
  module AtsApi
    module V1
      class UpdateVacancyService
        def initialize(vacancy, params)
          @vacancy = vacancy
          @params = params
        end

        def call
          validate_full_payload!

          if @vacancy.update(permitted_params)
            success_response
          else
            validation_error_response
          end
        end

        private

        attr_reader :vacancy, :params

        def validate_full_payload!
          missing_keys = required_keys - params.keys.map(&:to_sym)
          if missing_keys.any?
            raise ActionController::ParameterMissing, "Missing required parameters: #{missing_keys.join(', ')}"
          end
        end

        def required_keys
          %i[
            external_advert_url
            expires_at
            job_title
            skills_and_experience
            salary
            visa_sponsorship_available
            external_reference
            is_job_share
            job_roles
            working_patterns
            contract_type
            phases
            schools
          ]
        end

        def permitted_params
          params.permit(:external_advert_url, :external_reference, :visa_sponsorship_available, :is_job_share,
                        :expires_at, :job_title, :skills_and_experience, :is_parental_leave_cover, :salary, :job_advert, :contract_type,
                        job_roles: [], working_patterns: [], phases: [], schools: [:trust_uid, { school_urns: [] }])
        end

        def success_response
          {
            status: :ok,
            json: Publishers::AtsApi::V1::VacancySerialiser.new(vacancy: @vacancy).call,
          }
        end

        def validation_error_response
          {
            status: :unprocessable_entity,
            json: {
              errors: @vacancy.errors.messages.flat_map do |attribute, messages|
                messages.map { |message| { error: "#{attribute}: #{message}" } }
              end,
            },
          }
        end
      end
    end
  end
end
