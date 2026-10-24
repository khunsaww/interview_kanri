Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"

  resources :job_applications do
    resources :interviews, only: [:new, :create]
    resources :preparation_tasks, only: [:new, :create]
  end

  resources :interviews do
    resources :preparation_tasks, only: [:new, :create]
  end

  resources :preparation_tasks, only: [:edit, :update, :destroy]
  resource :sample_data, only: [:create, :destroy]
end
