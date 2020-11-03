namespace :vacancies do
  desc "Refreshes the cached pageviews for listed non expired job vacancies"
  namespace :statistics do
    namespace :backfill do
      task info_clicks: :environment do
        Vacancy.where(total_get_more_info_clicks: nil).each do |vacancy|
          click_count = PublicActivity::Activity.where(
            trackable: vacancy,
            key: "vacancy.get_more_information",
          ).count

          vacancy.total_get_more_info_clicks = click_count
          vacancy.save
        end
      end
    end
  end
end
