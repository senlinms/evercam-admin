Rails.application.routes.draw do
  root 'dashboard#index'

  resources :users do
    get :impersonate, on: :member
  end

  resources :cameras
  resources :vendors
  resources :vendor_models

  get '/map' => 'dashboard#map'
  get '/kpi' => 'dashboard#kpi'
end
