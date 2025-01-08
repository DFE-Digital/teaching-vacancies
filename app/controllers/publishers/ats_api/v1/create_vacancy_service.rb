module Publishers
  module AtsApi
    module V1
      class CreateVacancyService
        def initialize(params)
          @params = params
        end

        def call
          @vacancy = Vacancy.new(permitted_params)

          if conflict_vacancy
            return conflict_response(conflict_vacancy)
          end

          if @vacancy.save
            success_response
          else
            validation_error_response
          end
        end

        private

        attr_reader :params, :vacancy

        def permitted_params
          organisations = fetch_organisations(params[:schools])
          raise ActiveRecord::RecordNotFound, "No valid organisations found" if organisations.blank?

          params[:publish_on] ||= Time.zone.today.to_s
          params[:working_patterns] ||= []
          params[:phases] ||= []

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

        def conflict_vacancy
          Vacancy.find_by(external_reference: @vacancy.external_reference)
        end

        def conflict_response(conflict_vacancy)
          {
            status: :conflict,
            json: {
              error: "A vacancy with the provided external reference already exists",
            },
            headers: {
              "Link" => "<#{Rails.application.routes.url_helpers.vacancy_url(conflict_vacancy)}>; rel=\"existing\"",
            },
          }
        end

        def success_response
          { status: :created, json: { id: @vacancy.id } }
        end

        def validation_error_response
          {
            status: :unprocessable_entity,
            json: {
              errors: @vacancy.errors.messages.flat_map do |attr, messages|
                messages.map { |message| { error: "#{attr}: #{message}" } }
              end,
            },
          }
        end
      end
    end
  end
end
