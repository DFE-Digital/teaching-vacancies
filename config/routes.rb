require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  if Rails.env.development?
    mount Sidekiq::Web, at: "/sidekiq"
  else
    authenticate :support_user do
      mount Sidekiq::Web, at: "/sidekiq"
    end
  end

  get "check" => "application#check"

  if Rails.application.config.maintenance_mode
    # If in maintenance mode, route *all* requests to maintenance page
    match "*path", to: "errors#maintenance", via: :all
    root to: "errors#maintenance", as: "maintenance_root", via: :all
  end

  # Deprecated routes should have a redirect added in `routes/legacy_redirects.rb` after they are
  # removed from the routes (if at all possible), so our users don't get 404s:
  draw :legacy_redirects

  devise_for :jobseekers, controllers: {
    confirmations: "jobseekers/confirmations",
    passwords: "jobseekers/passwords",
    registrations: "jobseekers/registrations",
    sessions: "jobseekers/sessions",
    unlocks: "jobseekers/unlocks",
  }, path_names: {
    sign_in: "sign-in",
  }

  get "/jobseekers/saved_jobs", to: "jobseekers/saved_jobs#index", as: :jobseeker_root

  get "/organisation", to: "publishers/organisations#show", as: :publisher_root

  get "/sha", to: "sha#sha"

  get "/robots.txt", to: "robots#show"

  namespace :jobseekers do
    devise_scope :jobseeker do
      get :check_your_email, to: "registrations#check_your_email", as: :check_your_email
      get :check_your_email_password, to: "passwords#check_your_email_password", as: :check_your_email_password
      get :confirm_destroy, to: "registrations#confirm_destroy", as: :confirm_destroy_account
      get :resend_instructions, to: "registrations#resend_instructions", as: :resend_instructions
      post :confirm_email_address, to: "confirmations#show"
      post :unlock_account, to: "unlocks#show"
    end

    resources :job_applications, only: %i[index show destroy] do
      resources :build, only: %i[show update], controller: "job_applications/build"
      resources :employments, only: %i[new create edit update destroy], controller: "job_applications/employments"
      resources :breaks, only: %i[new create edit update destroy], controller: "job_applications/breaks" do
        get :confirm_destroy
      end
      resources :qualifications, only: %i[new create edit update destroy], controller: "job_applications/qualifications" do
        collection do
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

    resources :saved_jobs, only: %i[index]

    scope path: ":job_id" do
      resource :saved_job, only: %i[new destroy]
    end

    resources :subscriptions, only: %i[index]
    resource :account, only: %i[show]
    resource :account_feedback, only: %i[new create]
  end

  devise_for :publishers, controllers: {
    sessions: "publishers/sessions",
  }

  namespace :publishers do
    resource :account do
      get "confirm-unsubscribe", to: "accounts#confirm_unsubscribe"
      patch "unsubscribe", to: "accounts#unsubscribe"
    end
    resources :login_keys, only: %i[show new create]
    resource :new_features, only: %i[show update] do
      get :reminder
    end
    resources :notifications, only: %i[index]
    resources :publisher_preferences, only: %i[new create edit update destroy]
    resources :schools, only: %i[index show edit update]
    resource :terms_and_conditions, only: %i[show update]
    get :remove_organisation_filter, to: "publisher_preferences#remove_organisation"
  end

  scope :publishers do
    devise_scope :publisher do
      get "sign-in", to: "publishers/sessions#new", as: :new_publisher_session
      get "auth", to: "publishers/sessions#create", as: :create_publisher_session
      delete "sign-out", to: "publishers/sessions#destroy", as: :destroy_publisher_session
    end
  end

  scope path: "support-users" do
    devise_scope :support_user do
      get "sign-in", to: "support_users/sessions#new", as: :new_support_user_session
      delete "sign-out", to: "support_users/sessions#destroy", as: :destroy_support_user_session
    end

    root to: "support_users/dashboard#dashboard", as: :support_user_root
  end

  namespace :support_users, path: "support-users" do
    resources :fallback_sessions, only: %i[create show]

    get "feedback/general", to: "feedbacks#general"
    get "feedback/job-alerts", to: "feedbacks#job_alerts"
    get "feedback/satisfaction-ratings", to: "feedbacks#satisfaction_ratings"

    post "feedback/recategorize", to: "feedbacks#recategorize"
  end

  devise_for :support_users

  devise_scope :publisher do
    get "/auth/dfe", to: "omniauth_callbacks#passthru"
    get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
  end

  root "home#index"

  get "sitemap" => "sitemap#show", format: "xml"

  get "/pages/*id" => "pages#show", as: :page, format: false

  get "/:section/:post_name" => "posts#show",
      constraints: { section: /(jobseeker-guides|get-help-hiring)/, post_name: /[\w-]+/ },
      as: :post

  get "/:section" => "posts#index",
      constraints: { section: /(jobseeker-guides|get-help-hiring)/ },
      as: :posts

  get "/list-school-job" => "pages#show", defaults: { id: "list-school-job" }

  get "/cookies-preferences", to: "cookies_preferences#new", as: "cookies_preferences"
  post "/cookies-preferences", to: "cookies_preferences#create", as: "create_cookies_preferences"

  resources :updates, only: %i[index]

  resources :jobs, only: %i[index show], controller: "vacancies" do
    resources :documents, only: %i[show]
  end

  resource :feedback, only: %i[new create], controller: "general_feedbacks"
  resource :support_request, only: %i[new create]

  resources :subscriptions, except: %i[index show] do
    get :unsubscribe, on: :member

    resources :job_alert_feedbacks, only: %i[new update edit], controller: "jobseekers/job_alert_feedbacks"
    resources :unsubscribe_feedbacks, only: %i[new create], controller: "jobseekers/unsubscribe_feedbacks"
  end

  get "sign-up-for-ECT-job-alerts", to: "subscriptions#new", as: "ect_job_alerts", defaults: { ect_job_alert: true, search_criteria: { job_roles: ["ect_suitable"] } }

  namespace :api do
    scope "v:api_version", api_version: /1/ do
      resources :jobs, only: %i[index show], controller: "vacancies"
      get "/location_suggestion(/:location)", to: "location_suggestion#show", as: :location_suggestion
      resources :markers, only: %i[show]
    end

    resources :events, only: %i[create]
  end

  resource :organisation, only: %i[show edit update], controller: "publishers/organisations" do
    scope constraints: { type: /(published|draft|pending|expired|awaiting_feedback)/ } do
      get "jobs(/:type)", to: "publishers/organisations#show", defaults: { type: :published }, as: :jobs_with_type
    end

    resources :jobs, only: %i[create destroy delete show], controller: "publishers/vacancies" do
      resources :build, only: %i[show update], controller: "publishers/vacancies/build"
      resource :documents, only: %i[create destroy show], controller: "publishers/vacancies/documents"
      resource :application_forms, only: %i[create destroy], controller: "publishers/vacancies/application_forms"

      collection do
        get :create_or_copy, to: "publishers/vacancies#create_or_copy", path: "create-or-copy"
        get :select_a_job_for_copying, to: "publishers/vacancies#select_a_job_for_copying", path: "select-a-job-for-copying"
        get :redirect_to_copy_job, to: "publishers/vacancies#redirect_to_copy_job"
      end

      get :confirm_destroy
      get :preview
      post :publish, to: "publishers/vacancies/publish#create"
      get :publish, to: "publishers/vacancies/publish#create"
      get :review
      get :summary
      resource :activity_log, only: %i[show], controller: "publishers/vacancies/activity_log"
      resource :feedback, only: %i[create], controller: "publishers/vacancies/feedbacks"
      resource :expired_feedback, only: %i[new create], controller: "publishers/vacancies/expired_feedbacks", path: "expired-feedback" do
        get :submitted
      end
      resource :statistics, only: %i[show update], controller: "publishers/vacancies/statistics"
      resource :copy, only: %i[new create], controller: "publishers/vacancies/copy"
      resource :end_listing, only: %i[show update], controller: "publishers/vacancies/end_listing"
      resource :extend_deadline, only: %i[show update], controller: "publishers/vacancies/extend_deadline"

      resources :job_applications, only: %i[index show], controller: "publishers/vacancies/job_applications" do
        resources :notes, only: %i[index create destroy], controller: "publishers/vacancies/job_applications/notes"
        get :shortlist
        get :reject
        get :withdrawn
        post :update_status
      end
    end
  end

  # Well known URLs
  get ".well-known/change-password", to: redirect(status: 302) { Rails.application.routes.url_helpers.edit_jobseeker_registration_path(password_update: true) }

  get "/invalid-recaptcha", to: "errors#invalid_recaptcha", as: "invalid_recaptcha"
  match "/401", as: :unauthorised, to: "errors#unauthorised", via: :all
  match "/404", as: :not_found, to: "errors#not_found", via: :all
  match "/422", as: :unprocessable_entity, to: "errors#unprocessable_entity", via: :all
  match "/500", as: :internal_server_error, to: "errors#internal_server_error", via: :all
  match "/maintenance", as: :maintenance, to: "errors#maintenance", via: :all

  get "teaching-jobs-in-:location_landing_page_name",
      to: "vacancies#index",
      as: :location_landing_page,
      constraints: ->(params, _) { LocationLandingPage.exists?(params[:location_landing_page_name]) }

  get ":landing_page_slug",
      to: "vacancies#index",
      as: :landing_page,
      constraints: ->(params, _) { LandingPage.exists?(params[:landing_page_slug]) }

  get "/organisations/:organisation_landing_page_name",
      to: "vacancies#index",
      as: :organisation_landing_page,
      constraints: ->(params, _) { OrganisationLandingPage.exists?(params[:organisation_landing_page_name]) }
end
