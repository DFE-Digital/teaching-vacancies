module Publishers
  module Vacancies
    class JobApplicationsController < Publishers::Vacancies::JobApplications::BaseController
      include Jobseekers::QualificationFormConcerns
      include DatesHelper
      include JobApplicationsPdfHelper

      FORMS = {
        "TagForm" => Publishers::JobApplication::TagForm,
        "OfferedForm" => Publishers::JobApplication::OfferedForm,
        "DeclinedForm" => Publishers::JobApplication::DeclinedForm,
        "FeedbackForm" => Publishers::JobApplication::FeedbackForm,
        "InterviewDatetimeForm" => Publishers::JobApplication::InterviewDatetimeForm,
      }.freeze

      before_action :set_job_application, only: %i[show download pre_interview_checks messages download_messages]
      before_action :set_job_applications, only: %i[index tag update_tag offer]

      def index
        @form = Publishers::JobApplication::TagForm.new
      end

      def show
        redirect_to organisation_job_job_application_terminal_path(@vacancy.id, @job_application) if @job_application.withdrawn?
        @note = @job_application.notes.build

        raise ActionController::RoutingError, "Cannot view a draft application" if @job_application.draft?
      end

      def download
        document = submitted_application_form(@job_application)
        send_data(document.data, filename: document.filename, disposition: "inline")
      end

      def tag
        with_valid_form(@job_applications) do |form|
          case params[:tag_action]
          when "download" then download_selected(form.job_applications)
          when "export"   then export_selected(form.job_applications)
          when "declined" then render_declined_form(form.job_applications, form.origin)
          when "offered"  then render_offered_form(form.job_applications, form.origin)
          when "interview_datetime" then render_interview_datetime_form(form.job_applications, form.origin)
          when "unsuccessful_interview" then render_unsuccessful_interview_form(form.job_applications, form.origin)
          when "reject" then prepare_to_bulk_send(form.job_applications, :organisation_job_job_application_batch_bulk_rejection_message_path)
          when "message_shortlisted" then prepare_to_bulk_send(form.job_applications,
                                                               :organisation_job_job_application_batch_bulk_shortlisting_message_path)
          when "message_interviewing" then prepare_to_bulk_send(form.job_applications,
                                                                :organisation_job_job_application_batch_bulk_interviewing_message_path)
          else # when "update_status"
            render "tag"
          end
        end
      end

      def update_tag
        with_valid_form(@job_applications, validate_all_attributes: true) do |form|
          case form.status
          when "interviewing" then redirect_to_references_and_self_disclosure(form.job_applications)
          when "offered"      then render_offered_form(form.job_applications, form.origin)
          when "unsuccessful_interview" then render_unsuccessful_interview_form(form.job_applications, form.origin)
          else
            form.job_applications.each { it.update!(form.attributes) }
            redirect_to organisation_job_job_applications_path(@vacancy.id, anchor: form.origin)
          end
        end
      end

      def offer
        with_valid_form(@job_applications, validate_all_attributes: true) do |form|
          form.job_applications.each { it.update!(form.attributes) }
          redirect_to organisation_job_job_applications_path(@vacancy.id, anchor: form.origin)
        end
      end

      def terminal; end

      def pre_interview_checks
        @reference_requests = @job_application.referees.filter_map(&:reference_request)
      end

      def messages
        @show_form = params[:show_form]
        @message_form = Publishers::JobApplication::MessagesForm.new
        @messages = Message.joins(:conversation)
                           .includes(conversation: :job_application)
                           .with_rich_text_content_and_embeds
                           .merge(Conversation.where(job_application: @job_application))
                           .order(created_at: :desc)
        @back_link = params.fetch(:back_link, publishers_candidate_messages_path)

        # Mark jobseeker messages as read when publisher views them
        jobseeker_messages = @messages.select { |msg| msg.is_a?(JobseekerMessage) && msg.unread? }
        jobseeker_messages.each(&:mark_as_read!)
      end

      def download_messages
        messages = Message.joins(:conversation).where(conversations: { job_application: @job_application }).order(created_at: :desc)

        generator = MessagesPdfGenerator.new(@job_application, messages)
        document = generator.generate

        filename = "messages_#{@job_application.first_name}_#{@job_application.last_name}_#{@job_application.vacancy.job_title.parameterize}.pdf"

        send_data(document.render,
                  filename: filename,
                  type: "application/pdf",
                  disposition: "attachment")
      end

      private

      def set_job_applications
        @current_organisation = current_organisation
        @job_applications = @vacancy.job_applications.not_draft.within_hiring_staff_retention_period.order(updated_at: :desc).decorate
      end

      def with_valid_form(job_applications, validate_all_attributes: false)
        form_class = FORMS.fetch(params[:form_name], Publishers::JobApplication::TagForm)
        form_params = params
                        .fetch(ActiveModel::Naming.param_key(form_class), {})
                        .permit(:origin, :status, :offered_at, :declined_at, :interview_feedback_received, :interview_feedback_received_at, :interview_date, :interview_time, { job_applications: [] })
        form_params[:job_applications] = job_applications.select { |ja| form_params[:job_applications].include?(ja.id) }

        form_params[:validate_all_attributes] = validate_all_attributes

        @form = form_class.new(form_params)
        if @form.valid?
          yield @form
        else
          handle_form_errors(@form)
        end
      end

      def handle_form_errors(form)
        case form.errors.details
        in { status: }      then render "tag"
        in { offered_at: }  then render "offered_date"
        in { declined_at: } then render "declined_date"
        in { interview_feedback_received_at: } then render "feedback_date"
        in { interview_date: } then render "interview_datetime"
        in { interview_time: } then render "interview_datetime" # rubocop:disable Lint/DuplicateBranch
        in { job_application: } then render "interview_datetime" # rubocop:disable Lint/DuplicateBranch
        else
          flash[form.origin] = form.errors.full_messages
          redirect_to organisation_job_job_applications_path(@vacancy.id, anchor: form.origin)
        end
      end

      def prepare_to_bulk_send(job_applications, redirect_path)
        batch = JobApplicationBatch.create!(vacancy: @vacancy)
        job_applications.each do |ja|
          batch.batchable_job_applications.create!(job_application: ja)
        end
        redirect_to method(redirect_path).call(@vacancy.id, batch.id, Wicked::FIRST_STEP)
      end

      def download_selected(job_applications)
        zip_data = JobApplicationZipBuilder.new(vacancy: @vacancy, job_applications:).generate

        send_data(
          zip_data.string,
          filename: "applications_#{@vacancy.job_title.parameterize}.zip",
        )
      end

      def export_selected(selection)
        zip_data = ExportCandidateDataService.call(selection)
        send_data(zip_data.string, filename: "applications_offered_#{@vacancy.job_title}.zip")
      end

      def redirect_to_references_and_self_disclosure(job_applications)
        batch = JobApplicationBatch.create!(vacancy: @vacancy)
        job_applications.each do |ja|
          batch.batchable_job_applications.create!(job_application: ja)
        end
        redirect_to organisation_job_job_application_batch_references_and_self_disclosure_path(@vacancy.id, batch.id, Wicked::FIRST_STEP)
      end

      def render_declined_form(job_applications, origin)
        @form = Publishers::JobApplication::DeclinedForm.new(job_applications:, origin:, status: "declined")
        render "declined_date"
      end

      def render_offered_form(job_applications, origin)
        @form = Publishers::JobApplication::OfferedForm.new(job_applications:, origin:, status: "offered")
        render "offered_date"
      end

      def render_unsuccessful_interview_form(job_applications, origin)
        @form = Publishers::JobApplication::FeedbackForm.new(job_applications:, origin:, status: "unsuccessful_interview")
        render "feedback_date"
      end

      def render_interview_datetime_form(job_applications, origin)
        job_application = job_applications.first
        @form = Publishers::JobApplication::InterviewDatetimeForm.new(
          job_applications:,
          interview_date: job_application.interviewing_at,
          interview_time: job_application.interviewing_at&.to_fs(:time_only),
          origin:,
        )
        render "interview_datetime"
      end
    end
  end
end
