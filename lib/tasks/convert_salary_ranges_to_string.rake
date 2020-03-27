namespace :data do
  desc 'Convert salary ranges to strings for vacancies without the new salary field'
  namespace :convert_salary_ranges do
    task vacancies: :environment do
      pay_scales_array = ActiveRecord::Base.connection.execute(
        'SELECT * from pay_scales'
      ).as_json
      updated_count = 0
      should_be_updated_count = Vacancy.where(salary: [nil, '']).count

      Rails.logger.info(
        "Conversion of salary ranges to strings has been started for #{should_be_updated_count} vacancies"
      )
      Rollbar.log(
        :info,
        "Conversion of salary ranges to strings has been started for #{should_be_updated_count} vacancies"
      )

      Vacancy.where(salary: [nil, '']).in_batches(of: 100).each_record do |vacancy|
        min_pay_scale = vacancy.min_pay_scale_id.present? ?
          pay_scales_array.detect { |pay_scale| pay_scale['id'] == vacancy.min_pay_scale_id } : nil
        max_pay_scale = vacancy.max_pay_scale_id.present? ?
          pay_scales_array.detect { |pay_scale| pay_scale['id'] == vacancy.max_pay_scale_id } : nil
        pay_scales = [min_pay_scale.try(:[], 'label'), max_pay_scale.try(:[], 'label')].reject(&:blank?).join(' to ')
        minimum_salary = vacancy.minimum_salary.present? ?
          "£#{vacancy.minimum_salary.gsub(/\d(?=(...)+$)/, '\0,')}" : nil
        maximum_salary = vacancy.maximum_salary.present? ?
          "£#{vacancy.maximum_salary.gsub(/\d(?=(...)+$)/, '\0,')}" : nil
        salary_range = [minimum_salary, maximum_salary].reject(&:blank?).join(' to ')

        salary = [pay_scales, salary_range].reject(&:blank?).join(', ')
        if vacancy.pro_rata_salary?
          salary += ' per year pro rata'
        elsif vacancy.flexible_working?
          salary += ' per year (full-time equivalent)'
        end

        # Some vacancies being updated will have been created prior to certain validations
        # rubocop:disable Rails/SkipsModelValidations
        vacancy.update_columns(salary: salary)
        # rubocop:enable Rails/SkipsModelValidations
        updated_count += 1
        Rails.logger.info("Updated vacancy: #{vacancy.job_title} with salary: #{salary}")
      end

      Rails.logger.info("Conversion of salary ranges to strings has been completed for #{updated_count} vacancies")
      Rollbar.log(:info, "Conversion of salary ranges to strings has been completed for #{updated_count} vacancies")
    end
  end
end
