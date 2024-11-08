class SupportUsers::ApiClientsController < ApplicationController
  def index
    api_clients = ApiClient.all
    @pagy, @api_clients = pagy(api_clients)
  end

  def show
    @api_client = ApiClient.find(params[:id])
  end

  def rotate_key
    @api_client = ApiClient.find(params[:id])
    @api_client.rotate_api_key!
    redirect_to support_users_api_clients_path, notice: t("support_users.api_clients.key_rotation_success")
  end
end
