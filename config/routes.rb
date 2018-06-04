Rails.application.routes.draw do
  root 'vacancies#index'

  get 'check' => 'application#check'

  get '/pages/*id' => 'pages#show', as: :page, format: false

  resources :jobs, only: %i[index show], controller: 'vacancies' do
    resources :interests, only: %i[new]
  end

  # Backward compatibility after changing routes to 'jobs'
  resources :vacancies, only: [:show], controller: 'vacancies' do
    resources :interests, only: %i[new]
  end

  resource :sessions, controller: 'hiring_staff/sessions'

  get '/auth/azureactivedirectory/callback', to: 'hiring_staff/sessions#create'
  get '/auth/azureactivedirectory/failure', to: 'hiring_staff/sessions#failure'
  get '/auth/failure', to: 'hiring_staff/sessions#failure' # For OmniAuth testing only
  post '/auth/azureactivedirectory/callback', to: 'hiring_staff/sessions#create'

  resource :school, only: %i[show edit update], controller: 'hiring_staff/schools' do
    resources :jobs, only: %i[new edit destroy delete show], controller: 'hiring_staff/vacancies' do
      get 'review'
      get 'summary'
      post :publish, to: 'hiring_staff/vacancies/publish#create'
      resource :job_specification, only: %i[edit update],
                                   controller: 'hiring_staff/vacancies/job_specification'
      resource :candidate_specification, only: %i[edit update],
                                         controller: 'hiring_staff/vacancies/candidate_specification'
      resource :application_details, only: %i[edit update],
                                     controller: 'hiring_staff/vacancies/application_details'
    end

    resource :job, only: [] do
      get :job_specification, to: 'hiring_staff/vacancies/job_specification#new'
      post :job_specification, to: 'hiring_staff/vacancies/job_specification#create'
      get :candidate_specification, to: 'hiring_staff/vacancies/candidate_specification#new'
      post :candidate_specification, to: 'hiring_staff/vacancies/candidate_specification#create'
      get :application_details, to: 'hiring_staff/vacancies/application_details#new'
      post :application_details, to: 'hiring_staff/vacancies/application_details#create'
    end
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '*path', to: 'errors#not_found', via: :all
end
