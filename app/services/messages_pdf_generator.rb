class MessagesPdfGenerator
  include Prawn::View
  include PdfUiHelper

  def initialize(job_application, messages)
    @job_application = job_application
    @messages = messages
    @document = Prawn::Document.new(page_size: "A4", margin: 1.cm)
  end

  def generate
    page_style
    messages_page_header
    page_footer("#{job_application.first_name} #{job_application.last_name} | #{job_application.vacancy.organisation_name}")
    render_messages

    number_pages "<page> of <total>",
                 at: [bounds.right - 50, bounds.bottom - 10],
                 size: 8

    @document
  end

  private

  attr_reader :job_application, :messages

  def messages_page_header
    page_header do
      text "Messages for #{job_application.vacancy.job_title}", size: 12, style: :italic
      move_down 0.5.cm
      text "#{job_application.first_name} #{job_application.last_name}", size: 22, style: :bold
    end
  end

  def render_messages
    page_section do
      page_title("Messages")

      if messages.empty?
        text "No messages yet.", size: 12
        return
      end

      messages.each_with_index do |message, index|
        render_message(message)
        move_down 20 if index < messages.length - 1
      end
    end
  end

  def render_message(message)
    sender_name = message_sender_name(message)
    timestamp = message.created_at.strftime("%d %B %Y at %I:%M %p")
    content_text = ActionController::Base.helpers.strip_tags(message.content.to_s)

    # Use page_table for consistent formatting with other PDFs
    message_data = [
      ["From:", sender_name],
      ["Date:", timestamp],
      ["Message:", content_text],
    ]

    page_table(message_data)
    move_down 0.5.cm
  end

  def message_sender_name(message)
    case message.class.name
    when "JobseekerMessage"
      "#{job_application.first_name} #{job_application.last_name} (Candidate)"
    else
      publisher_name = "#{message.sender.given_name} #{message.sender.family_name}".strip
      "#{publisher_name} - #{job_application.vacancy.organisation_name} (Hiring staff)"
    end
  end
end
