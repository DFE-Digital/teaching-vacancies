require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/ats-api-docs"
  mount Rswag::Api::Engine => "/ats-api-docs"

  if Rails.env.development?
    mount Sidekiq::Web, at: "/sidekiq"
  else
    authenticate :support_user do
      mount Sidekiq::Web, at: "/sidekiq"
    end
  end

  get "check" => "application#check"

  get "/get-help-hiring/how-to-approve-access-for-hiring-staff", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-setup-your-account", post_name: "how-to-approve-access-for-hiring-staff")
  }
  get "/get-help-hiring/how-to-request-organisation-access", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-setup-your-account", post_name: "how-to-request-organisation-access")
  }
  get "/get-help-hiring/how-mats-can-use-teaching-vacancies", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-setup-your-account", post_name: "how-mats-can-use-teaching-vacancies")
  }
  get "/get-help-hiring/how-to-list-non-teaching-roles", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "how-to-list-non-teaching-roles")
  }
  get "/get-help-hiring/creating-the-perfect-teacher-job-advert", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "creating-the-perfect-teacher-job-advert")
  }
  get "/get-help-hiring/accepting-job-applications-on-teaching-vacancies", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "accepting-job-applications-on-teaching-vacancies")
  }
  get "/get-help-hiring/communicating-with-jobskeers", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "communicating-with-jobseekers")
  }
  get "/jobseeker-guides/write-a-great-teaching-job-application-in-five-steps", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "write-a-great-teaching-job-application-in-five-steps")
  }
  get "/jobseeker-guides/how-to-write-teacher-personal-statement", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "how-to-write-teacher-personal-statement")
  }
  get "/jobseeker-guides/prepare-for-a-teaching-job-interview-lesson", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "prepare-for-a-teaching-job-interview-lesson")
  }
  get "/jobseeker-guides/how-to-approach-a-teaching-job-interview", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "how-to-approach-a-teaching-job-interview")
  }
  get "/jobseeker-guides/3-quick-ways-to-find-the-right-teaching-job", to: redirect { |_params, _request|
    Rails.application.routes.url_helpers.post_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: "3-quick-ways-to-find-the-right-teaching-job")
  }

  # Deprecated routes should have a redirect added in `routes/legacy_redirects.rb` after they are
  # removed from the routes (if at all possible), so our users don't get 404s:
  draw :legacy_redirects

  devise_for :jobseekers, controllers: {
    registrations: "jobseekers/registrations",
    sessions: "jobseekers/sessions",
  }, path_names: {
    sign_in: "sign-in",
  }

  get "/jobseekers/saved_jobs", to: "jobseekers/saved_jobs#index", as: :jobseeker_root

  get "/organisation", to: "publishers/vacancies#index", as: :publisher_root, defaults: { signing_in: "true" }

  get "/sha", to: "sha#sha"

  get "/robots.txt", to: "robots#show"

  namespace :jobseekers do
    devise_scope :jobseeker do
      delete "/", to: "registrations#destroy", as: :destroy_account
      get :confirm_destroy, to: "registrations#confirm_destroy", as: :confirm_destroy_account
    end

    resources :login_keys, only: %i[new create] do
      get :consume, on: :member
    end

    resources :uploaded_job_applications, only: [] do
      resource :personal_details, only: %i[edit update], module: :uploaded_job_applications
      resource :upload_application_form, only: %i[edit update], module: :uploaded_job_applications
    end

    resources :job_applications, only: %i[index show destroy] do
      resources :form_previews, only: %i[show]
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
      resources :referees, only: %i[new create edit update destroy], controller: "job_applications/referees"
      resources :training_and_cpds, only: %i[new create edit update destroy], controller: "job_applications/training_and_cpds"
      resources :professional_body_memberships, only: %i[new create edit update destroy], controller: "job_applications/professional_body_memberships"
      get :apply
      post :pre_submit
      get :review
      get :confirm_destroy
      get :confirm_withdraw
      post :submit
      get :post_submit
      post :withdraw
      get :download
      resource :feedback, only: %i[create], controller: "job_applications/feedbacks"
      resources :messages, only: %i[create], controller: "job_applications/messages"
      resources :self_disclosure, only: %i[show update], controller: "job_applications/self_disclosure" do
        get :completed, on: :collection
      end
    end

    scope as: :job, path: ":job_id" do
      resource :job_application, only: %i[new create]
      resource :uploaded_job_application, only: %i[create], controller: "uploaded_job_applications"
    end

    resource :profile, only: %i[show] do
      resource :preview, only: :show, controller: "profiles/preview"
      resource :about_you, only: %i[edit update show], controller: "profiles/about_you"
      resources :work_history, only: %i[new create edit update destroy], controller: "profiles/employments" do
        get :review, on: :collection, to: "profiles/employments#review"
      end
      resource :qualified_teacher_status, only: %i[edit update show], controller: "profiles/qualified_teacher_status"
      get "personal-details", to: "profiles/personal_details#start"
      get "personal-details/:step", to: "profiles/personal_details#edit", as: :edit_personal_details
      post "personal-details/:step", to: "profiles/personal_details#update"
      resources :qualifications, only: %i[new create edit update destroy], controller: "profiles/qualifications" do
        get :review, on: :collection, to: "profiles/qualifications#review"
        collection do
          get :select_category
          post :submit_category
        end
        get :confirm_destroy
      end
      resources :training_and_cpds, only: %i[new create edit update destroy], controller: "profiles/training_and_cpds" do
        get :review, on: :collection, to: "profiles/training_and_cpds#review"
        get :confirm_destroy
      end
      resources :professional_body_memberships, only: %i[new create edit update destroy], controller: "profiles/professional_body_memberships" do
        get :review, on: :collection, to: "profiles/professional_body_memberships#review"
        get :confirm_destroy
      end

      resources :breaks, only: %i[new create edit update destroy], controller: "profiles/breaks" do
        get :confirm_destroy
      end

      resource :hide_profile, only: %i[show], controller: "profiles/hide_profile" do
        post :confirm_hide
        get :add
        post :add_school
        get :choose_school_or_trust
        post :add_school_or_trust
        get :cannot_find_school
        get :schools
        post :add_another
        get :review

        get ":exclusion_id/delete", action: :delete, as: :delete
        delete ":exclusion_id/delete", action: :destroy
      end

      get "confirm_toggle", to: "profiles#confirm_toggle"
      post "toggle", to: "profiles#toggle"
    end

    scope controller: "profiles/job_preferences", path: "profile/job-preferences" do
      get "review", action: :review, as: nil
      get "location(/:id)", action: :edit_location, as: nil
      post "location(/:id)", action: :update_location, as: nil

      get "location/:id/delete", action: :delete_location, as: nil
      post "location/:id/delete", action: :process_delete_location, as: nil

      get "", action: :start, as: :job_preferences
      get ":step", action: :edit, as: :job_preferences_step
      post ":step", action: :update, as: nil
    end

    resources :saved_jobs, only: %i[index]

    scope path: ":job_id" do
      resource :saved_job, only: %i[new destroy]
    end

    resources :subscriptions, only: %i[index]
    resource :account, only: %i[show] do
      member do
        get :account_found
        get :account_not_found
      end
      resource :email_preferences, only: %i[edit update]
    end
    resource :account_feedback, only: %i[new create]
    resource :request_account_transfer_email, only: %i[new create]
    resource :account_transfer, only: %i[new create]

    resources :notifications, only: %i[index]
  end

  devise_for :publishers, controllers: {
    sessions: "publishers/sessions",
  }

  namespace :publishers do
    resource :account do
      # Unsubscribe from expired vacancy feedback emails
      get "confirm-unsubscribe", to: "accounts#confirm_unsubscribe"
      patch "unsubscribe", to: "accounts#unsubscribe"
      # Opt out from mail communications from Teaching Vacancies
      get "confirm-email-opt-out", to: "accounts#confirm_email_opt_out"
      patch "email-opt-out", to: "accounts#email_opt_out"
    end
    resources :login_keys, only: %i[show new create] do
      post :consume, on: :member
    end
    resources :jobseeker_profiles, only: %i[index show]
    resources :candidate_messages, only: %i[index] do
      collection do
        patch :toggle_archive
      end
    end
    resource :new_features, only: %i[] do
      get :reminder
    end
    resources :current_year_statistics, only: %i[index] do
      collection do
        get :equal_opportunities
      end
    end
    resources :all_time_statistics, only: %i[index] do
      collection do
        get :equal_opportunities
      end
    end
    resources :notifications, only: %i[index]
    resources :publisher_preferences, only: %i[new create edit update destroy]
    resources :organisations, only: %i[show] do
      resource :description, only: %i[edit update], controller: "organisations/description"
      resource :email, only: %i[edit update], controller: "organisations/email"
      resource :safeguarding_information, only: %i[edit update], controller: "organisations/safeguarding_information"
      resource :logo, only: %i[edit update destroy], controller: "organisations/logo" do
        get :confirm_destroy
      end
      resource :photo, only: %i[edit update destroy], controller: "organisations/photo" do
        get :confirm_destroy
      end
      resource :website, only: %i[edit update], controller: "organisations/url_override"

      get :preview
      get :profile_incomplete
      get "schools/preview", to: "/publishers/organisations/schools#preview"
    end
    resource :terms_and_conditions, only: %i[show update]
    resource :candidate_profiles_interstitial, only: %i[show]
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

    get "service-data", to: "service_data#index"
    namespace :service_data, path: "service-data" do
      resources :jobseeker_profiles, only: %i[index show]
    end

    resources :publisher_ats_api_clients do
      post :rotate_key, on: :member
    end
  end

  devise_for :support_users

  scope path: "jobseekers" do
    devise_scope :jobseeker do
      get "/auth/govuk_one_login/callback/", to: "jobseekers/govuk_one_login_callbacks#openid_connect"
      get "/sign-in", to: "jobseekers/sessions#new", as: :new_jobseeker_session
      post "/sign-in", to: "jobseekers/sessions#create", as: :create_jobseeker_session
      delete "/sign_out", to: "jobseekers/sessions#destroy", as: :destroy_jobseeker_session # Handle AuthenticationFallbackForJobseekers sign out
      get "/sign_out", to: "jobseekers/sessions#destroy", as: :jobseekers_sign_out # Handle GovukOneLogin sign out 'post_logout_redirect_uri'
    end
  end

  devise_scope :publisher do
    get "/auth/dfe", to: "omniauth_callbacks#passthru"
    get "/auth/dfe/callback", to: "omniauth_callbacks#dfe"
  end

  root "home#index"

  get "sitemap" => "sitemap#show", format: "xml"

  get "/pages/*id" => "pages#show", as: :page, format: false

  get "/:section" => "posts#index",
      constraints: { section: /(jobseeker-guides|get-help-hiring|transcripts)/ },
      as: :posts

  get "/:section/:subcategory" => "posts#subcategory",
      constraints: { section: /(jobseeker-guides|get-help-hiring|transcripts)/, subcategory: /get-help-applying-for-your-teaching-role|return-to-teaching-in-england|how-to-create-job-listings-and-accept-applications|how-to-setup-your-account|jobseekers/ },
      as: :subcategory

  get "/:section/:subcategory/:post_name" => "posts#show",
      constraints: { section: /(jobseeker-guides|get-help-hiring|transcripts)/, subcategory: /get-help-applying-for-your-teaching-role|return-to-teaching-in-england|how-to-create-job-listings-and-accept-applications|how-to-setup-your-account|jobseekers/, post_name: /[\w-]+/ },
      as: :post

  get "/list-school-job" => "pages#show", defaults: { id: "list-school-job" }

  get "/cookies-preferences", to: "cookies_preferences#new", as: "cookies_preferences"
  post "/cookies-preferences", to: "cookies_preferences#create", as: "create_cookies_preferences"

  resources :updates, only: %i[index]

  resources :jobs, only: %i[index show], controller: "vacancies" do
    resources :documents, only: %i[show]
  end

  resources :organisations, only: %i[index show], path: "schools" do
    resources :schools, only: %i[index], controller: "organisations/schools"
  end

  resource :feedback, only: %i[new create], controller: "general_feedbacks"
  resource :support_request, only: %i[new create]

  resources :subscriptions, except: %i[index show] do
    get :unsubscribe, on: :member

    get :submit_feedback, controller: "jobseekers/subscriptions/feedbacks/relevance_feedbacks"

    resources :feedbacks do
      resources :further_feedbacks, only: %i[new create], controller: "jobseekers/subscriptions/feedbacks/further_feedbacks"
    end
    resources :unsubscribe_feedbacks, only: %i[new create], controller: "jobseekers/unsubscribe_feedbacks"
  end

  get "sign-up-for-ECT-job-alerts", to: "subscriptions#new", as: "ect_job_alerts", defaults: { ect_job_alert: true, search_criteria: { teaching_job_roles: ["ect_suitable"] } }

  namespace :api do
    scope "v:api_version", api_version: /1/ do
      resources :jobs, only: %i[index show], controller: "vacancies"
      get "/location_suggestion(/:location)", to: "location_suggestion#show", as: :location_suggestion
      get "/organisations", to: "organisations#index", as: :organisations
      resources :markers, only: %i[show]
    end

    resources :events, only: %i[create]
  end

  scope path: "ats-api" do
    scope module: "publishers/ats_api/v1", path: "v1" do
      resources :vacancies, only: %i[index show create update destroy], format: :json
    end
  end

  scope "/organisation", as: "organisation" do
    scope constraints: { type: /(live|draft|pending|expired|awaiting_feedback)/ } do
      get "jobs(/:type)", to: "publishers/vacancies#index", defaults: { type: :live }, as: :jobs_with_type
    end
    get "/jobs/start", to: "publishers/vacancies#start"

    resources :jobs, only: %i[create destroy show], controller: "publishers/vacancies" do
      resources :build, only: %i[show update], controller: "publishers/vacancies/build"
      resources :wizard, only: %i[show update], controller: "publishers/vacancies/wizard"
      resources :documents, only: %i[index new create destroy], controller: "publishers/vacancies/documents" do
        post :confirm, on: :collection
      end
      resource :application_forms, only: %i[create destroy], controller: "publishers/vacancies/application_forms"

      get :confirm_destroy
      get :convert_to_draft
      get :preview
      resources :form_previews, only: %i[show], controller: "publishers/vacancies/form_previews"
      get :review
      post :publish, to: "publishers/vacancies/publish#create"
      get :publish, to: "publishers/vacancies/publish#create"
      post :save_and_finish_later
      get :summary
      resource :activity_log, only: %i[show], controller: "publishers/vacancies/activity_log"
      resource :feedback, only: %i[create], controller: "publishers/vacancies/feedbacks"
      resource :expired_feedback, only: %i[new create], controller: "publishers/vacancies/expired_feedbacks", path: "expired-feedback" do
        get :submitted
      end
      resource :statistics, only: %i[show update], controller: "publishers/vacancies/statistics"
      resource :copy, only: %i[create], controller: "publishers/vacancies/copy"
      resource :relist, only: %i[create edit update], controller: "publishers/vacancies/relist"
      resource :end_listing, only: %i[show update], controller: "publishers/vacancies/end_listing"
      resource :extend_deadline, only: %i[show update], controller: "publishers/vacancies/extend_deadline"

      resources :job_applications, only: %i[index show], controller: "publishers/vacancies/job_applications" do
        resources :notes, only: %i[create destroy], controller: "publishers/vacancies/job_applications/notes"
        resources :messages, only: %i[create], controller: "publishers/vacancies/job_applications/messages"
        resources :reference_requests, only: %i[show update edit], controller: "publishers/vacancies/job_applications/reference_requests" do
          member do
            patch :mark_as_received
            patch :mark_as_complete
            patch :send_reminder_email
          end
        end
        get :download
        get :terminal
        get :tag, on: :collection
        post :update_tag, on: :collection
        post :offer, on: :collection
        member do
          get :pre_interview_checks
        end
        resource :religious_reference, only: %i[edit update], controller: "publishers/vacancies/job_applications/religious_references"
        member do
          get :messages
          get :download_messages
        end
        resource :self_disclosure, only: %i[show update], controller: "publishers/vacancies/job_applications/self_disclosure"
        resources :collect_reference_flags, only: %i[show update], controller: "publishers/vacancies/collect_reference_flags"
        resources :collect_self_disclosure_flags, only: %i[show update], controller: "publishers/vacancies/collect_self_disclosure_flags"
      end
      resources :job_application_batches, only: %i[] do
        resources :references_and_self_disclosure, only: %i[show update], controller: "publishers/vacancies/references_and_self_disclosure"
      end
      resources :bulk_rejection_messages, only: %i[], controller: "publishers/vacancies/bulk_rejection_messages" do
        member do
          get :select_rejection_template
          get :prepare_rejection_emails
          post :send_rejection_emails
        end
      end
    end

    resources :message_templates, only: %i[new create edit update destroy], controller: "publishers/message_templates"
  end

  resources :references, only: %i[] do
    resources :build, only: %i[show update], controller: "referees/build_references" do
      collection do
        get :completed
        get :no_reference
      end
    end
  end

  # Well known URLs
  get ".well-known/change-password", to: redirect(status: 302) { "https://home.account.gov.uk/security" }

  match "/401", as: :unauthorised, to: "errors#unauthorised", via: :all
  match "/404", as: :not_found, to: "errors#not_found", via: :all
  match "/422", as: :unprocessable_entity, to: "errors#unprocessable_entity", via: :all
  match "/500", as: :internal_server_error, to: "errors#internal_server_error", via: :all

  get "campaigns/",
      to: "vacancies#campaign_landing_page",
      as: :campaign_landing_page,
      constraints: ->(request) { CampaignPage.exists?(request.params[:utm_content]) }

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
