namespace :data do
  desc 'Import organisations data'

  namespace :organisations do
    task create: :environment do
      School.in_batches(of: 100).each_record.each do |school|
        Organisation.create(school.attributes)
      end

      SchoolGroup.in_batches(of: 100).each_record.each do |school_group|
        Organisation.create(school_group.attributes)
      end

      # rubocop:disable Rails/SkipsModelValidations
      Organisation.where('urn IS NOT NULL').update_all(type: 'School')
      Organisation.where('uid IS NOT NULL').update_all(type: 'SchoolGroup')
      # rubocop:enable Rails/SkipsModelValidations
    end

    desc 'Update vacancies'
    task update_vacancies: :environment do
      Vacancy.in_batches(of: 500).each_record.each do |vacancy|
        vacancy.organisation_vacancies.create(organisation_id: vacancy.school_id) if vacancy.school_id
        vacancy.organisation_vacancies.create(organisation_id: vacancy.school_group_id) if vacancy.school_group_id
      end
    end
  end
end
