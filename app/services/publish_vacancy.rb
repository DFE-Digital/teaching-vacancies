class PublishVacancy
  class << self
    def call(vacancy, current_publisher, current_organisation)
      CopyVacancy.new(vacancy, RealVacancy).call.tap do |new_vacancy|
        new_vacancy.assign_attributes(publisher_organisation: current_organisation,
                                      publisher: current_publisher,
                                      status: :published)
        new_vacancy.save
        vacancy.destroy
      end
    end
  end
end
