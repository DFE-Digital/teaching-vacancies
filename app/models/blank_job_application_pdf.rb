class BlankJobApplicationPdf < JobApplicationPdf
  Table = Data.define(:rows) do
    include Enumerable
    extend Forwardable

    def_delegators :blanked_rows, :each, :==, :<<, :empty?

    def blanked_rows
      rows.map { [it.first, nil] }
    end
  end

  def initialize(job_application)
    super
    @table_class = Table
  end

  def applicant_name
    "________________________"
  end

  def footer_text
    vacancy.organisation_name
  end

  def personal_statement
    ""
  end
end
