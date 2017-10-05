Rails.application.routes.draw do
  root 'vacancies#index'

  resources :vacancies, only: %i[index show new create edit] do
    get 'publish', on: :member
  end

  match '*path', to: 'application#not_found', via: %i[get post patch put delete]
end
