class SupportUsers::PublisherAtsApiClientsController < SupportUsers::BaseController
  def index
    api_clients = PublisherAtsApiClient.all
    @pagy, @api_clients = pagy(api_clients)
  end

  def show
    @api_client = PublisherAtsApiClient.find(params[:id])
  end

  def new
    @api_client = PublisherAtsApiClient.new
  end

  def create
    @api_client = PublisherAtsApiClient.new(api_client_params)
    if @api_client.save
      redirect_to support_users_publisher_ats_api_client_path(@api_client), notice: t("support_users.publisher_ats_api_clients.creation_success")
    else
      flash.now[:alert] = t("support_users.publisher_ats_api_clients.creation_failure")
      render :new
    end
  end

  def confirm_rotate_key
    @api_client = PublisherAtsApiClient.find(params[:id])
  end

  def rotate_key
    @api_client = PublisherAtsApiClient.find(params[:id])
    @api_client.rotate_api_key!
    redirect_to support_users_publisher_ats_api_clients_path, notice: t("support_users.publisher_ats_api_clients.key_rotation_success")
  end

  private

  def api_client_params
    params.expect(publisher_ats_api_client: [:name])
  end
end
