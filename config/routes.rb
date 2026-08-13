Rails.application.routes.draw do
  resource :session, only: %i[new create destroy] do
    post :switch
  end

  resources :leads, only: %i[index show update] do
    member do
      post :note
      post :reopen
    end
  end
  resources :locations, only: :index
  resource :newsletter, only: :show, controller: :newsletter
  resource :insights, only: :show, controller: :insights
  resources :reports, only: %i[index show create]
  resource :workspace, only: :show, controller: :workspace do
    resources :locations, only: :create, module: :workspace
    resources :websites, only: :create, module: :workspace do
      post :rotate, on: :member
    end
    resources :memberships, only: :create, module: :workspace
    resources :features, only: :update, module: :workspace
  end
  resource :recruiting, only: :show, controller: :recruiting do
    resources :positions, only: %i[create update], controller: "recruiting/job_postings"
    resources :applications, only: %i[show update], controller: "recruiting/job_applications"
  end
  namespace :agency do
    resources :tenants, only: %i[index create]
  end

  namespace :v1 do
    get "dashboard/summary", to: "dashboard#summary"
    resources :events, only: :create
    resources :leads, only: %i[index create show update] do
      member do
        post :notes
        post :reopen
      end
    end
    resources :job_applications, only: :create
    resources :locations, only: :index
    resources :reports, only: %i[index show]
  end

  root "dashboard#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
