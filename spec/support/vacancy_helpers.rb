module VacancyHelpers

  def fill_vacancy_fields(vacancy)
    fill_in 'vacancy[job_title]', with: vacancy.job_title
    fill_in 'vacancy[headline]', with: vacancy.headline
    fill_in 'vacancy[job_description]', with: vacancy.job_description
    select vacancy.working_pattern.humanize, from: 'vacancy[working_pattern]'
    fill_in 'vacancy[minimum_salary]', with: vacancy.minimum_salary
    fill_in 'vacancy[maximum_salary]', with: vacancy.maximum_salary
    fill_in 'vacancy[essential_requirements]', with: vacancy.essential_requirements
    select Faker::Business.credit_card_expiry_date.day, from: 'vacancy[expires_on(3i)]'
    select Faker::Business.credit_card_expiry_date.strftime("%B"), from: 'vacancy[expires_on(2i)]'
    select Faker::Business.credit_card_expiry_date.year, from: 'vacancy[expires_on(1i)]'

    click_button 'Save and continue'
  end

  def vacancy_salary_range(min, max, del="to")
    "#{number_to_currency(min, precision: 0)} #{del} #{number_to_currency(max, precision: 0)}"
  end

  def expect_schema_property_to_match_value(key, value)
    expect(page).to have_selector("meta[itemprop='#{key}'][content='#{value}']")
  end

  def skip_vacancy_publish_on_validation
    allow_any_instance_of(Vacancy).to receive(:validity_of_publish_on).and_return(true)
  end
end
