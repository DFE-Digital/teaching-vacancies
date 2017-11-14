Rails.application.routes.draw do
  root 'vacancies#index'


  resources :vacancies, only: %i[index show new create edit] do
    get 'review', on: :member
    put 'publish', on: :member
    get 'published', on: :member
  end

  resources :schools, only: [:index] do
    get 'search', on: :collection
  end

  resources :schools, only: %i[show edit update]


  match '*path', to: 'application#not_found', via: %i[get post patch put delete]
end
