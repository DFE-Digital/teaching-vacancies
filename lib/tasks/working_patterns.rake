# rubocop:disable Metrics/BlockLength
namespace :vacancies do
  desc "Remove old working patterns from vacancies"
  task remove_working_patterns: :environment do
    # these are the working_patterns that we want to remove
    old_patterns = [102, 103, 104]
    # query to find vacancies where at least one of the old working patterns is included in the working_patterns
    vacancies = Vacancy.where("working_patterns && ARRAY[?]::integer[]", old_patterns)

    vacancies.each do |vacancy|
      # remove the old working patterns
      new_working_patterns = vacancy.working_patterns - ["term_time", "flexible", nil]
      # add "part_time" to replace the old working pattern unless it is already there.
      new_working_patterns << "part_time" unless vacancy.working_patterns.include?("part_time")
      vacancy.update(working_patterns: new_working_patterns)
    end
  end

  desc "Remove incorrectly copied legacy working patterns details from newer vacancies since legacy field was deprecated on 25th August 2022"
  task remove_copied_legacy_working_patterns_details: :environment do
    Vacancy.where("((full_time_details IS NOT NULL AND full_time_details != '') OR (part_time_details IS NOT NULL AND part_time_details != '')) " \
                  "AND working_patterns_details IS NOT NULL " \
                  "AND working_patterns_details != '' " \
                  "AND created_at >= '2022-08-25'").update_all(working_patterns_details: nil)
  end

  desc "Backfill working patterns details from full/part time details"
  task backfill_working_patterns_details: :environment do
    Vacancy.where("((full_time_details IS NOT NULL AND full_time_details != '') OR (part_time_details IS NOT NULL AND part_time_details != '')) " \
                  "AND ((working_patterns_details IS NULL) OR (working_patterns_details = '')) " \
                  "AND created_at >= '2022-08-25'").find_each do |vacancy|
      data = if vacancy.full_time_details.present? && vacancy.part_time_details.present?
               "Full time #{vacancy.full_time_details.strip}#{'.' unless vacancy.full_time_details.strip.end_with?('.')} Part time #{vacancy.part_time_details.strip}"
             elsif vacancy.full_time_details.present?
               vacancy.full_time_details
             elsif vacancy.part_time_details.present?
               vacancy.part_time_details
             end
      vacancy.update(working_patterns_details: data)
    end
  end
end
# rubocop:enable Metrics/BlockLength
