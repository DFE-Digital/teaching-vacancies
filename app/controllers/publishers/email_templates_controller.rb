module Publishers
  class EmailTemplatesController < ApplicationController
    def new
      @email_template = email_templates.new
    end

    def edit
      @email_template = email_templates.find_by(id: params[:id])
    end

    def create
      @email_template = email_templates.create email_template_params
      if @email_template.persisted?
        redirect_to session[:template_return_path], success: t(".success")
      else
        render "new"
      end
    end

    def update
      @email_template = email_templates.find_by(id: params[:id])
      if @email_template.update email_template_params
        redirect_to session[:template_return_path], success: t(".success")
      else
        render "edit"
      end
    end

    def destroy
      email_template = email_templates.find_by(id: params[:id])
      email_template.destroy!
      redirect_to session[:template_return_path]
    end

    private

    def email_templates
      current_publisher.email_templates.rejection
    end

    def email_template_params
      params.expect(email_template: %i[name from subject content])
    end
  end
end
