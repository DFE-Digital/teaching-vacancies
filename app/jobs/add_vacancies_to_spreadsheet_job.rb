require 'add_vacancies_to_spreadsheet'

class AddVacanciesToSpreadsheetJob < ApplicationJob
  queue_as :audit_vacancies

  def perform
    AddVacanciesToSpreadsheet.new.run!
  end
end
