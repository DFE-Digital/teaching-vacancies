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
  end
end
