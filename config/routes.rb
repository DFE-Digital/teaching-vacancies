Rails.application.routes.draw do
  root 'vacancies#index'

  get 'check' => 'application#check'

  resources :vacancies, only: %i[index show new create update] do
    get 'review', on: :member
    resource :job_specification, only: :show, controller: :vacancies, action: :job_specification
    resource :candidate_specification, only: :show, controller: :vacancies, action: :candidate_specification
    resource :application_details, only: :show, controller: :vacancies, action: :application_details

    put 'publish', on: :member
    get 'published', on: :member
  end

  resources :schools, only: %i[index show edit update], controller: 'hiring_staff/schools' do
    get 'search', on: :collection
    resources :vacancies, only: %i[new create update edit delete show], controller: 'hiring_staff/vacancies' do
      # Legacy form routing copied over
      get 'review', on: :member
      put 'publish', on: :member
      get 'published', on: :member
      resource :job_specification, only: :show, controller: 'hiring_staff/vacancies', action: :job_specification
      resource :candidate_specification,
               only: :show, controller: 'hiring_staff/vacancies',
               action: :candidate_specification
      resource :application_details, only: :show, controller: 'hiring_staff/vacancies', action: :application_details
    end
  end

  match '*path', to: 'application#not_found', via: %i[get post patch put delete]
end
