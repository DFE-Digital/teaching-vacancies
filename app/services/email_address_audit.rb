class EmailAddressAudit
  EMAIL_CLASSES = {
    Feedback => :email,
    JobApplication => :email_address,
    Jobseeker => :email,
    Publisher => :email,
    Subscription => :email,
    Vacancy => :contact_email,
  }.freeze

  class << self
    def run(list: false, delete: false)
      EMAIL_CLASSES.each_with_object({}) do |(klass, method), hash|
        invalid_records = klass.find_each.with_object([]) do |record, array|
          address = record.public_send(method)
          if address.present? && EmailAddressValidator.invalid?(address)
            array << record
          end
        end

        invalid_addresses = invalid_records.map(&method)

        hash[klass.name] = list ? invalid_addresses.sort : invalid_addresses.count

        invalid_records.each(&:destroy) if delete
      end
    end
  end
end
