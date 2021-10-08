module Vacancy::Indexable
  extend ActiveSupport::Concern

  INDEX_NAME = [Rails.configuration.algolia_index_prefix, DOMAIN, Vacancy].compact.join("-").freeze

  included do
    include AlgoliaSearch
    include ActionView::Helpers::SanitizeHelper
    include DatesHelper

    scope :unindexed, (-> { live.where(initially_indexed: false) })

    algoliasearch index_name: INDEX_NAME, auto_index: !Rails.env.test?, auto_remove: !Rails.env.test?, if: :listed? do
      attributes :education_phases, :job_roles, :job_title, :parent_organisation_name, :salary, :subjects, :working_patterns, :_geoloc

      attribute :about_school do
        strip_tags(about_school)&.truncate(256)
      end

      attribute :benefits do
        strip_tags(benefits)
      end

      attribute :expires_at do
        format_time_to_datetime_at(expires_at)
      end

      attribute :expires_at_timestamp do
        expires_at&.to_i
      end

      attribute :job_roles_for_display do
        presenter.show_job_roles
      end

      attribute :job_advert do
        strip_tags(job_advert)&.truncate(256)
      end

      attribute :key_stages do
        presenter.show_key_stages
      end

      attribute :last_updated_at do
        updated_at.to_i
      end

      attribute :organisations do
        { names: organisations.map(&:name),
          counties: organisations.map(&:county).uniq,
          detailed_school_types: organisations.schools.map(&:detailed_school_type).uniq,
          group_type: organisations.school_groups.map(&:group_type).reject(&:blank?).uniq,
          local_authorities_within: organisations.map(&:local_authority_within).reject(&:blank?).uniq,
          religious_characters: organisations.schools.map(&:religious_character).reject(&:blank?).uniq,
          regions: organisations.schools.map(&:region).uniq,
          school_types: organisations.schools.map { |org| org.school_type&.singularize }.uniq,
          towns: organisations.map(&:town).reject(&:blank?).uniq }
      end

      attribute :publication_date do
        publish_on&.to_s
      end

      attribute :publication_date_timestamp do
        publish_on&.to_time&.to_i
      end

      attribute :school_visits do
        strip_tags(school_visits)
      end

      attribute :start_date do
        starts_on&.to_s
      end

      attribute :start_date_timestamp do
        starts_on&.to_time&.to_i
      end

      attribute :subjects_for_display do
        presenter.show_subjects
      end

      attribute :working_patterns_for_display do
        presenter.working_patterns
      end

      attributesForFaceting %i[job_roles working_patterns education_phases subjects]

      add_replica "#{INDEX_NAME}_publish_on_desc", inherit: true do
        ranking ["desc(publication_date_timestamp)"]
      end

      add_replica "#{INDEX_NAME}_expires_at_desc", inherit: true do
        ranking ["desc(expires_at_timestamp)"]
      end

      add_replica "#{INDEX_NAME}_expires_at_asc", inherit: true do
        ranking ["asc(expires_at_timestamp)"]
      end
    end
  end

  def _geoloc
    organisations.select { |organisation| organisation.geopoint.present? }
                 .map { |organisation| { lat: organisation.geopoint.lat, lng: organisation.geopoint.lon } }
  end

  def presenter
    @presenter ||= VacancyPresenter.new(self)
  end

  class_methods do
    # NOTE: the `if: :listed?` filter in the `algoliasearch` definition *only* excludes records from being *added* to
    # the index. It DOES NOT prevent the ruby client from checking that the record exists in the Algolia index in the
    # first place. Even if the record should not be in the index (unpublished or expired records), the client still
    # consumes an Algolia operation to try and look it up if it appears in canonical list of records returned by the
    # model.
    #
    # To illustrate: if you run the unmodified `Vacancy.reindex!` on a recent (2020-06-18) production dataset you will
    # consume more than 30,000 operations on the Algolia app. This occurs because it looks up each of the 30,000+
    # expired/unpublished records before it applies the `:listed?` filter. It only indexes about 470 records. I am not
    # 100% certain, but it seems this is done so it can remove records that should not be in the index according to the
    # filter.
    #
    # If, however, you run `Vacancy.live.reindex!`, which scopes the list to only the "published" records, it only
    # consumes slightly more operation than there are indexable records.
    def reindex!
      live.includes(organisation_vacancies: :organisation).algolia_reindex!
    end

    def reindex
      live.includes(organisation_vacancies: :organisation).algolia_reindex
    end

    # This is the main method you should use most of the time when bulk-adding new records to the algolia index. It will
    # not use any additional operations checking records that have been indexed once. NOTE: if a record has been indexed
    # already and it is updated with new or additional information, the `auto_index: true` will do the work of keeping the
    # changes in sync with the algolia index. This method is solely for preventing us paying for unnecessary usage when
    # adding records that have become `live` since the last time it was run.
    def update_index!
      unindexed.algolia_reindex!
      unindexed.update_all(initially_indexed: true)
    end

    def remove_vacancies_that_expired_yesterday!
      index.delete_objects(expired_yesterday.map(&:id)) if expired_yesterday&.any?
    end
  end
end
