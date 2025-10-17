module Publishers
  class MessageTemplatesController < ApplicationController
    def new
      @message_template = message_templates.new
    end

    def edit
      @message_template = message_templates.find_by(id: params[:id])
    end

    def create
      @message_template = message_templates.create message_template_params
      if @message_template.persisted?
        redirect_to session[:template_return_path], success: t(".success")
      else
        render "new"
      end
    end

    def update
      @message_template = message_templates.find_by(id: params[:id])
      if @message_template.update message_template_params
        redirect_to session[:template_return_path], success: t(".success")
      else
        render "edit"
      end
    end

    def destroy
      message_template = message_templates.find_by(id: params[:id])
      message_template.destroy!
      redirect_to session[:template_return_path]
    end

    private

    def message_templates
      current_publisher.message_templates.rejection
    end

    def message_template_params
      params.expect(message_template: %i[name content])
    end
  end
end
