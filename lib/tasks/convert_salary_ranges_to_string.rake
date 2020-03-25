namespace :data do
  desc 'Convert salary ranges to strings for vacancies without the new salary field'
  namespace :convert_salary_ranges do
    task vacancies: :environment do
      Rails.logger.info('Conversion of salary ranges to strings has been started')
      Rollbar.log(:info, 'Conversion of salary ranges to strings has been started')

      pay_scales_array = PayScale.all.as_json

      Vacancy.where(salary: [nil, '']).in_batches.each_record do |vacancy|
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

        vacancy.update(salary: salary)
        Rails.logger.info("Updated vacancy: #{vacancy.job_title} with salary: #{salary}")
      end

      Rails.logger.info('Conversion of salary ranges to strings has been completed')
      Rollbar.log(:info, 'Conversion of salary ranges to strings has been completed')
    end
  end
end
