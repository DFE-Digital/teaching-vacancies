Rails.application.routes.draw do
  root "pages#home"

  get "check" => "application#check"
  get "sitemap" => "sitemap#show", format: "xml"

  get "/pages/*id" => "pages#show", as: :page, format: false

  get "/cookies-preferences", to: "cookies_preferences#new", as: "cookies_preferences"
  post "/cookies-preferences", to: "cookies_preferences#create", as: "create_cookies_preferences"

  resources :updates, only: %i[index]

  resources :jobs, only: %i[index show], controller: "vacancies" do
    resources :interests, only: %i[new]
  end

  # Backward compatibility after changing routes to 'jobs'
  resources :vacancies, only: [:show], controller: "vacancies" do
    resources :interests, only: %i[new]
  end

  resource :feedback, controller: "general_feedback", only: %i[new create]

  resources :subscriptions, only: %i[new create edit update] do
    get :unsubscribe, on: :member
    resources :job_alert_feedbacks, only: %i[new update edit]
  end

  get "sign-up-for-NQT-job-alerts", to: "nqt_job_alerts#new", as: "nqt_job_alerts"
  post "sign-up-for-NQT-job-alerts", to: "nqt_job_alerts#create", as: "new_nqt_job_alert"

  namespace :api do
    scope "v:api_version", api_version: /[1]/ do
      resources :jobs, only: %i[index show], controller: "vacancies"
      get "/coordinates(/:location)", to: "coordinates#show"
      get "/location_suggestion(/:location)", to: "location_suggestion#show"
    end
  end

  resources :stats, only: [:index]

  resource :identifications, only: %i[new create], controller: "hiring_staff/identifications"

  # Sign in
  resource :sessions, only: %i[destroy], controller: "hiring_staff/sessions"

  # Authentication fallback with emailed magic link
  get "auth/email/sessions/new", to: "hiring_staff/sign_in/email/sessions#new",
                                 as: "new_auth_email"
  post "auth/email/sessions/check-your-email", to: "hiring_staff/sign_in/email/sessions#check_your_email",
                                               as: "auth_email_check_your_email"
  get "auth/email/sessions/choose-organisation", to: "hiring_staff/sign_in/email/sessions#choose_organisation",
                                                 as: "auth_email_choose_organisation"
  get "auth/email/sessions/sign-in", to: "hiring_staff/sign_in/email/sessions#create",
                                     as: "auth_email_create_session"
  get "auth/email/sessions/sign-out", to: "hiring_staff/sign_in/email/sessions#destroy",
                                      as: "auth_email_sign_out"
  get "auth/email/sessions/change-organisation", to: "hiring_staff/sign_in/email/sessions#change_organisation",
                                                 as: "auth_email_change_organisation"

  # DfE Sign In
  resource :sessions,
           only: %i[create new],
           as: :dfe,
           path: "/dfe/sessions",
           controller: "hiring_staff/sign_in/dfe/sessions"

  get "/auth/dfe/callback", to: "hiring_staff/sign_in/dfe/sessions#create"
  get "/auth/dfe/signout", to: "hiring_staff/sign_in/dfe/sessions#destroy"
  get "/auth/failure", to: "hiring_staff/sign_in/dfe/sessions#new"

  resource :terms_and_conditions, only: %i[show update], controller: "hiring_staff/terms_and_conditions"

  resource :organisation, only: %i[show edit update], controller: "hiring_staff/organisations" do
    scope constraints: { type: /(published|draft|pending|expired|awaiting_feedback)/ } do
      get "jobs(/:type)", to: "hiring_staff/organisations#show", defaults: { type: :published }, as: :jobs_with_type
    end
    resources :jobs, only: %i[new edit destroy delete show], controller: "hiring_staff/vacancies" do
      get "review",
          defaults: { create_step: 8, step_title: I18n.t("jobs.review_heading") }
      get "preview"
      get "summary"
      post :publish, to: "hiring_staff/vacancies/publish#create"
      get :publish, to: "hiring_staff/vacancies/publish#create"
      resource :job_location,
               only: %i[show update],
               controller: "hiring_staff/vacancies/job_location",
               defaults: { create_step: 1, step_title: I18n.t("jobs.job_location") }
      resource :schools,
               only: %i[show update],
               controller: "hiring_staff/vacancies/schools",
               defaults: { create_step: 1, step_title: I18n.t("jobs.job_location") }
      resource :job_specification,
               only: %i[show update],
               controller: "hiring_staff/vacancies/job_specification",
               defaults: { create_step: 2, step_title: I18n.t("jobs.job_details") }
      resource :pay_package,
               only: %i[show update],
               controller: "hiring_staff/vacancies/pay_package",
               defaults: { create_step: 3, step_title: I18n.t("jobs.pay_package") }
      resource :important_dates,
               only: %i[show update],
               controller: "hiring_staff/vacancies/important_dates",
               defaults: { create_step: 4, step_title: I18n.t("jobs.important_dates") }
      resource :supporting_documents,
               only: %i[show update],
               controller: "hiring_staff/vacancies/supporting_documents",
               defaults: { create_step: 5, step_title: I18n.t("jobs.supporting_documents") }
      resource :documents,
               only: %i[create destroy show],
               controller: "hiring_staff/vacancies/documents",
               defaults: { create_step: 5, step_title: I18n.t("jobs.supporting_documents") }
      resource :application_details,
               only: %i[show update],
               controller: "hiring_staff/vacancies/application_details",
               defaults: { create_step: 6, step_title: I18n.t("jobs.application_details") }
      resource :job_summary,
               only: %i[show update],
               controller: "hiring_staff/vacancies/job_summary",
               defaults: { create_step: 7, step_title: I18n.t("jobs.job_summary") }
      resource :feedback, controller: "hiring_staff/vacancies/vacancy_publish_feedback", only: %i[new create]
      resource :statistics, controller: "hiring_staff/vacancies/statistics", only: %i[update]
      resource :copy, only: %i[new create],
                      controller: "hiring_staff/vacancies/copy"
    end

    # When there is no job_id, i.e. when we want the starting step for job creation
    resource :job, only: [] do
      get :job_location,
          to: "hiring_staff/vacancies/job_location#show",
          defaults: { create_step: 1, step_title: I18n.t("jobs.job_location") }
      post :job_location,
           to: "hiring_staff/vacancies/job_location#create",
           defaults: { create_step: 1, step_title: I18n.t("jobs.job_location") }
      get :schools,
          to: "hiring_staff/vacancies/schools#show",
          defaults: { create_step: 1, step_title: I18n.t("jobs.job_location") }
      post :schools,
           to: "hiring_staff/vacancies/schools#create",
           defaults: { create_step: 1, step_title: I18n.t("jobs.job_location") }
      get :job_specification,
          to: "hiring_staff/vacancies/job_specification#show",
          defaults: { create_step: 2, step_title: I18n.t("jobs.job_details") }
      post :job_specification,
           to: "hiring_staff/vacancies/job_specification#create",
           defaults: { create_step: 2, step_title: I18n.t("jobs.job_details") }
    end

    resources :schools, only: %i[index edit update], controller: "hiring_staff/organisations/schools"
    resource :managed_organisations, only: %i[show update],
                                     controller: "hiring_staff/organisations/managed_organisations"
  end

  match "/401", to: "errors#unauthorised", via: :all
  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "*path", to: "errors#not_found", via: :all

  # External URL

  direct :roll_out_blog do
    "https://dfedigital.blog.gov.uk/2018/09/21/how-were-rolling-out-our-search-and-listing-service-to-more-schools-to-support-their-teacher-recruitment-needs/"
  end
end
