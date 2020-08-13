namespace :data do
  desc 'Import organisations data'

  namespace :organisations do
    task create: :environment do
      School.all.each do |school|
        Organisation.create(school.attributes)
      end

      SchoolGroup.all.each do |school_group|
        Organisation.create(school_group.attributes)
      end
    end

    desc 'Update organisations data'
    task update: :environment do
      # rubocop:disable Rails/SkipsModelValidations
      Organisation.where('urn IS NOT NULL').update_all(type: 'School')
      Organisation.where('uid IS NOT NULL').update_all(type: 'SchoolGroup')
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
