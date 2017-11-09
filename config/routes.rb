Rails.application.routes.draw do
  root 'vacancies#index'

  resources :schools, only: %i[show edit update]

  resources :vacancies, only: %i[index show new create edit] do
    get 'review', on: :member
    put 'publish', on: :member
    get 'published', on: :member
  end

  match '*path', to: 'application#not_found', via: %i[get post patch put delete]
end
