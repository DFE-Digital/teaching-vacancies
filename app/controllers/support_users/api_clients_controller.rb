class SupportUsers::ApiClientsController < SupportUsers::BaseController
  def index
    api_clients = ApiClient.all
    @pagy, @api_clients = pagy(api_clients)
  end

  def show
    @api_client = ApiClient.find(params[:id])
  end

  def new
    @api_client = ApiClient.new
  end

  def create
    @api_client = ApiClient.new(api_client_params)
    if @api_client.save
      redirect_to support_users_api_client_path(@api_client), notice: t("support_users.api_clients.creation_success")
    else
      flash.now[:alert] = t("support_users.api_clients.creation_failure")
      render :new
    end
  end

  def rotate_key
    @api_client = ApiClient.find(params[:id])
    @api_client.rotate_api_key!
    redirect_to support_users_api_clients_path, notice: t("support_users.api_clients.key_rotation_success")
  end

  private

  def api_client_params
    params.require(:api_client).permit(:name)
  end
end
