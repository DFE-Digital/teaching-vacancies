Rails.application.routes.draw do
  resources :vacancies, only: [:index]
end
