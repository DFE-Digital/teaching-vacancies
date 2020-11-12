module AddressHelper
  def address_join(address_lines)
    # For SchoolGroup address data points, GIAS sometimes lists 'Not recorded' in their spreadsheet.
    address_lines.reject { |address_line| address_line.blank? || address_line.casecmp("not recorded").zero? }.join(", ")
  end
end
