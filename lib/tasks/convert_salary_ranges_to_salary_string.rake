namespace :data do
  desc 'Convert salary ranges to string'
  namespace :convert_salary_ranges do
    task vacancies: :environment do
      Vacancy.in_batches.each_record do |vacancy|
        min_pay_scale = vacancy.min_pay_scale_id.present? ? PayScale.find(vacancy.min_pay_scale_id) : nil
        max_pay_scale = vacancy.max_pay_scale_id.present? ? PayScale.find(vacancy.max_pay_scale_id) : nil
        pay_scales = [min_pay_scale&.label, max_pay_scale&.label].reject(&:blank?).join(' to ')
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
      end
    end
  end
end
