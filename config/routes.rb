require "sidekiq/web"

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end
  mount Sidekiq::Web, at: "/sidekiq"

  constraints(-> { JobseekerAccountsFeature.enabled? }) do
    devise_for :jobseekers, controllers: {
      confirmations: "jobseekers/confirmations",
      passwords: "jobseekers/passwords",
      registrations: "jobseekers/registrations",
      sessions: "jobseekers/sessions",
      unlocks: "jobseekers/unlocks",
    }

    get "/jobseekers/saved_jobs", to: "jobseekers/saved_jobs#index", as: :jobseeker_root

    namespace :jobseekers do
      devise_scope :jobseeker do
        get :check_your_email, to: "registrations#check_your_email", as: :check_your_email
        get :check_your_email_password, to: "passwords#check_your_email_password", as: :check_your_email_password
      end

      constraints(-> { JobseekerApplicationsFeature.enabled? }) do
        scope path: ":job_id" do
          resources :job_applications, only: %i[new create]
        end

        resources :job_applications, only: [] do
          resources :build, only: %i[show update], controller: "job_applications/build"
          get :review
          post :submit
        end
      end

      scope path: ":job_id" do
        resources :saved_jobs, only: %i[new destroy]
      end

      resources :saved_jobs, only: %i[index]
      resources :subscriptions, only: %i[index]
      resource :account, only: %i[show]
      resource :account_feedback, only: %i[new create]
    end
  end

  root "home#index"

  get "check" => "application#check"
  get "sitemap" => "sitemap#show", format: "xml"

  get "/pages/*id" => "pages#show", as: :page, format: false

  get "/cookies-preferences", to: "cookies_preferences#new", as: "cookies_preferences"
  post "/cookies-preferences", to: "cookies_preferences#create", as: "create_cookies_preferences"

  resources :updates, only: %i[index]

  resources :jobs, only: %i[index show], controller: "vacancies" do
    resources :interests, only: %i[new]
  end

  resource :feedback, controller: "general_feedback", only: %i[new create]

  resources :subscriptions, only: %i[new create edit update] do
    get :unsubscribe, on: :member
    post :unsubscribe_feedback, on: :member
    resources :job_alert_feedbacks, only: %i[new update edit]
  end

  get "sign-up-for-NQT-job-alerts", to: "nqt_job_alerts#new", as: "nqt_job_alerts"
  post "sign-up-for-NQT-job-alerts", to: "nqt_job_alerts#create", as: "new_nqt_job_alert"

  namespace :api do
    scope "v:api_version", api_version: /1/ do
      resources :jobs, only: %i[index show], controller: "vacancies"
      get "/location_suggestion(/:location)", to: "location_suggestion#show"
    end
  end

  resource :identifications, only: %i[new create], controller: "publishers/identifications"

  # Sign in
  resource :sessions, only: %i[destroy], controller: "publishers/sessions"

  # Authentication fallback with emailed magic link
  get "auth/email/sessions/new", to: "publishers/sign_in/email/sessions#new",
                                 as: "new_auth_email"
  post "auth/email/sessions/check-your-email", to: "publishers/sign_in/email/sessions#check_your_email",
                                               as: "auth_email_check_your_email"
  get "auth/email/sessions/choose-organisation", to: "publishers/sign_in/email/sessions#choose_organisation",
                                                 as: "auth_email_choose_organisation"
  get "auth/email/sessions/sign-in", to: "publishers/sign_in/email/sessions#create",
                                     as: "auth_email_create_session"
  get "auth/email/sessions/sign-out", to: "publishers/sign_in/email/sessions#destroy",
                                      as: "auth_email_sign_out"
  get "auth/email/sessions/change-organisation", to: "publishers/sign_in/email/sessions#change_organisation",
                                                 as: "auth_email_change_organisation"

  # DfE Sign In
  resource :sessions,
           only: %i[create new],
           as: :dfe,
           path: "/dfe/sessions",
           controller: "publishers/sign_in/dfe/sessions"

  get "/auth/dfe/callback", to: "publishers/sign_in/dfe/sessions#create"
  get "/auth/dfe/signout", to: "publishers/sign_in/dfe/sessions#destroy"
  get "/auth/failure", to: redirect("/dfe/sessions/new", status: 303)

  resource :terms_and_conditions, only: %i[show update], controller: "publishers/terms_and_conditions"

  resource :organisation, only: %i[show edit update], controller: "publishers/organisations" do
    scope constraints: { type: /(published|draft|pending|expired|awaiting_feedback)/ } do
      get "jobs(/:type)", to: "publishers/organisations#show", defaults: { type: :published }, as: :jobs_with_type
    end

    resources :jobs, only: %i[create edit destroy delete show], controller: "publishers/vacancies" do
      resources :build, only: %i[show update], controller: "publishers/vacancies/build"
      resource :documents, only: %i[create destroy show], controller: "publishers/vacancies/documents"
      get "review"
      get "preview"
      get "summary"
      post :publish, to: "publishers/vacancies/publish#create"
      get :publish, to: "publishers/vacancies/publish#create"
      resource :feedback, controller: "publishers/vacancies/vacancy_publish_feedback", only: %i[new create]
      resource :statistics, controller: "publishers/vacancies/statistics", only: %i[update]
      resource :copy, only: %i[new create],
                      controller: "publishers/vacancies/copy"
    end

    resources :schools, only: %i[index edit update], controller: "publishers/organisations/schools"
    resource :managed_organisations, only: %i[show update],
                                     controller: "publishers/organisations/managed_organisations"
  end

  post "/errors/csp_violation", to: "errors#csp_violation"
  get "/invalid-recaptcha", to: "errors#invalid_recaptcha", as: "invalid_recaptcha"
  match "/401", to: "errors#unauthorised", via: :all
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # If parameters are used that are the same as those in the search form, pagination with kaminari will break
  match "teaching-jobs-in-:location_category",
        to: "vacancies#index", as: :location_category, via: :get,
        constraints: ->(request) { LocationCategory.include?(request.params[:location_category]) }

  match "teaching-jobs-for-:job_role",
        to: "vacancies#index", as: :job_role, via: :get,
        constraints: ->(request) { Vacancy.job_roles.key?(request.params[:job_role]) },
        defaults: { pretty: :job_role }

  match "teaching-jobs-for-:subject",
        to: "vacancies#index", as: :subject, via: :get,
        constraints: ->(request) { SUBJECT_OPTIONS.map(&:first).include?(request.params[:subject]) },
        defaults: { pretty: :subject }

  match "*path", to: "errors#not_found", via: :all
end
