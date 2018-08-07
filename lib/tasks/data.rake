namespace :data do
  desc 'Import school data'
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.new.perform
    end
  end

  desc 'import Local Authority and assigned Rergional PayScale data'
  namespace :local_authorities do
    task import: :environment do
      Rails.logger.debug("Running data:local_authority:import task in #{Rails.env}")
      location = Rails.root.join('lib', 'tasks', 'data', 'local_authorities.json')
      data = File.read(location)
      json_data = JSON.parse(data)
      begin
        json_data['local_authorities'].each do |local_authority|
          LocalAuthority.transaction do
            la = LocalAuthority.create(code:  local_authority['code'], name: local_authority['name'])
            local_authority['payscales'].each do |ps|
              la.regional_pay_band_areas << RegionalPayBandArea.find_or_initialize_by(name: ps['name'])
            end
          end
        end
      rescue ActiveRecord::RecordNotUnique
        Rails.logger.error('Local authority data already populated.')
      end
    end
  end
end
