module ProfileSection
  extend ActiveSupport::Concern

  class_methods do
    def prepare(**)
      find_or_initialize_by(**).tap do |record|
        if record.new_record?
          prepare_associations(record)
          complete_steps(record)

          record.save!
        end
      end
    end

    def prepare_associations(_record); end
    def complete_steps(_record); end
  end
end
