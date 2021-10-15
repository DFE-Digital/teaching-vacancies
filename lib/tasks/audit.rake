namespace :audit do
  desc "List the number of invalid email addresses per class.  Pass `list` to see actual addresses, and/or `delete` to delete the invalid records."
  task :email_addresses, %i[arg1 arg2] => :environment do |_, args|
    options = {
      delete: args.to_a.include?("delete"),
      list: args.to_a.include?("list"),
    }

    if options[:delete]
      puts "Warning, this will delete all records that have invalid email addresses!"
      puts "Please type 'delete' to confirm, or anything else to cancel."

      next unless gets.chomp == "delete"

      puts "Deletion confirmed."
    end

    pp EmailAddressAudit.run(**options)
  end
end
