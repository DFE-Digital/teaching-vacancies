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

  def religious_information
    if vacancy.catholic?
      catholic_religious_information
    else
      other_religious_information
    end
  end

  private

  def catholic_religious_information
    [
      ["Are you currently following a religion or faith?", "Yes / No"],
      ["What is your religious denomination or faith?", nil],
      ["Address of place of worship (optional)", nil],
      ["Can you provide a religious referee?", "Yes / No"],
      ["If yes, please provide the below information for your religious referee", nil],
      ["Name", nil],
      ["Address", nil],
      ["Role", nil],
      ["Email", nil],
      ["Phone number (optional)", nil],
      ["if you cannot provide a religious referee, can you provide a baptism certificate?", "If yes, please enclose a copy of your certificate."],
      ["If you cannot provide a religious referee or a baptism certificate, con you provide the date and address of your baptism?", "Yes / No / Not applicable"],
      ["if yes, please provide the below information", nil],
      ["Address of baptism location", nil],
      ["Date of your baptism", nil],
      ["Please tick here if you cannot provide a religious referee, a baptism certificate or the date and address of your baptism.", nil],
    ]
  end

  def other_religious_information
    [
      ["How will you support the school's ethos and aims", nil],
      ["Are you currently following a religion or faith?", "Yes / No"],
      ["What is your religious denomination or faith?", nil],
      ["Address of place of worship (optional)", nil],
      ["Can you provide religious referee?", "Yes / No"],
      ["If yes, please provide the below information for your religious referee", nil],
      ["Name", nil],
      ["Address", nil],
      ["Roles", nil],
      ["Email", nil],
      ["Phone number (optional)", nil],
    ]
  end
end
