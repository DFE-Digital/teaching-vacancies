Rails.application.routes.draw do
  root 'vacancies#index'

  resources :vacancies, only: %i[index show new]

  match '*path', to: 'application#not_found', via: %i[get post patch put delete]
end
