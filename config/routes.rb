require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  unless Rails.env.development?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
    end
  end
  mount Sidekiq::Web, at: "/sidekiq"

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
      resources :job_applications, only: %i[index show destroy] do
        resources :build, only: %i[show update], controller: "job_applications/build"
        resources :employments, only: %i[new create edit update destroy], controller: "job_applications/employments"
        resources :qualifications, only: %i[new create edit update], controller: "job_applications/qualifications" do
          collection do
            delete :destroy, as: :destroy
            get :select_category
            post :submit_category
          end
        end
        resources :references, only: %i[new create edit update destroy], controller: "job_applications/references"
        get :review
        get :confirm_destroy
        get :confirm_withdraw
        post :submit
        post :withdraw
        resource :feedback, only: %i[create], controller: "job_applications/feedbacks"
      end

      scope as: :job, path: ":job_id" do
        resource :job_application, only: %i[new create] do
          get :new_quick_apply
          post :quick_apply
        end
      end
    end

    resources :saved_jobs, only: %i[index]

    scope path: ":job_id" do
      resource :saved_job, only: %i[new destroy]
    end

    resources :subscriptions, only: %i[index]
    resource :account, only: %i[show]
    resource :account_feedback, only: %i[new create]
  end

  devise_for :publishers, controllers: {
    omniauth_callbacks: "publishers/omniauth_callbacks",
    sessions: "publishers/sessions",
  }

  namespace :publishers do
    resources :notifications, only: %i[index]
  end

  scope :publishers do
    devise_scope :publisher do
      get "sign_in", to: "publishers/sessions#new", as: :new_publisher_session
      delete "sign_out", to: "publishers/sessions#destroy", as: :destroy_publisher_session
    end

    # Authentication fallback with emailed magic link
    get "auth/email/sessions/new", to: "publishers/sign_in/email/sessions#new",
                                   as: "new_auth_email"
    post "auth/email/sessions/check-your-email", to: "publishers/sign_in/email/sessions#check_your_email",
                                                 as: "auth_email_check_your_email"
    get "auth/email/sessions/choose-organisation", to: "publishers/sign_in/email/sessions#choose_organisation",
                                                   as: "auth_email_choose_organisation"
    get "auth/email/sessions/sign-in", to: "publishers/sign_in/email/sessions#create",
                                       as: "auth_email_create_session"

    resources :publisher_preferences, only: %i[new create edit update], controller: "publishers/publisher_preferences"
  end

  root "home#index"

  get "check" => "application#check"
  get "sitemap" => "sitemap#show", format: "xml"

  get "/pages/*id" => "pages#show", as: :page, format: false

  get "/cookies-preferences", to: "cookies_preferences#new", as: "cookies_preferences"
  post "/cookies-preferences", to: "cookies_preferences#create", as: "create_cookies_preferences"

  resources :updates, only: %i[index]
  resources :documents, only: %i[show]

  resources :jobs, only: %i[index show], controller: "vacancies" do
    resources :interests, only: %i[new]
  end

  resources :shares, only: %i[new]

  resource :feedback, only: %i[new create], controller: "general_feedbacks"

  resources :subscriptions, except: %i[index show] do
    get :unsubscribe, on: :member

    resources :job_alert_feedbacks, only: %i[new update edit], controller: "jobseekers/job_alert_feedbacks"
    resources :unsubscribe_feedbacks, only: %i[new create], controller: "jobseekers/unsubscribe_feedbacks"
  end

  get "sign-up-for-NQT-job-alerts", to: "subscriptions#new", as: "nqt_job_alerts", defaults: { nqt_job_alert: true, origin: "/sign-up-for-NQT-job-alerts", search_criteria: { job_roles: ["nqt_suitable"] } }

  namespace :api do
    scope "v:api_version", api_version: /1/ do
      resources :jobs, only: %i[index show], controller: "vacancies"
      get "/location_suggestion(/:location)", to: "location_suggestion#show", as: :location_suggestion
    end
  end

  resource :terms_and_conditions, only: %i[show update], controller: "publishers/terms_and_conditions"

  resource :organisation, only: %i[show edit update], controller: "publishers/organisations" do
    scope constraints: { type: /(published|draft|pending|expired|awaiting_feedback)/ } do
      get "jobs(/:type)", to: "publishers/organisations#show", defaults: { type: :published }, as: :jobs_with_type
    end

    resources :jobs, only: %i[create edit destroy delete show], controller: "publishers/vacancies" do
      resources :build, only: %i[show update], controller: "publishers/vacancies/build"
      resource :documents, only: %i[create destroy show], controller: "publishers/vacancies/documents"
      get :review
      get :preview
      get :summary
      post :publish, to: "publishers/vacancies/publish#create"
      get :publish, to: "publishers/vacancies/publish#create"
      resource :feedback, only: %i[create], controller: "publishers/vacancies/feedbacks"
      resource :statistics, only: %i[update], controller: "publishers/vacancies/statistics"
      resource :copy, only: %i[new create], controller: "publishers/vacancies/copy"
      resource :end_listing, only: %i[show update], controller: "publishers/vacancies/end_listing"
      resource :extend_deadline, only: %i[show update], controller: "publishers/vacancies/extend_deadline"

      constraints(-> { JobseekerApplicationsFeature.enabled? }) do
        resources :job_applications, only: %i[index show], controller: "publishers/vacancies/job_applications" do
          get :shortlist
          get :reject
          post :update_status
        end
      end
    end

    resources :schools, only: %i[index edit update], controller: "publishers/organisations/schools"
  end

  # Legacy publisher sign in path (users may still have this bookmarked)
  get "/identifications/new", to: redirect("/publishers/sign_in")

  # Well known URLs
  get ".well-known/change-password", to: redirect(status: 302) { Rails.application.routes.url_helpers.edit_jobseeker_registration_path(password_update: true) }

  post "/errors/csp_violation", to: "errors#csp_violation"
  get "/invalid-recaptcha", to: "errors#invalid_recaptcha", as: "invalid_recaptcha"
  match "/401", as: :unauthorised, to: "errors#unauthorised", via: :all
  match "/404", as: :not_found, to: "errors#not_found", via: :all
  match "/422", as: :unprocessable_entity, to: "errors#unprocessable_entity", via: :all
  match "/500", as: :internal_server_error, to: "errors#internal_server_error", via: :all

  # If parameters are used that are the same as those in the search form, pagination with kaminari will break
  match "teaching-jobs-in-:location_facet",
        to: "vacancies#index", as: :location, via: :get,
        constraints: ->(request) { LocationPolygon.include?(request.params[:location_facet]) }

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
