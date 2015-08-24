Rails.application.routes.draw do
  root to: 'dashboard#index'

  devise_options = {
      controllers: {
          registrations: 'registrations'
      }
  }
  devise_for :users, devise_options

  resources :users, only: [:show, :index, :update] do
    get :impersonate, on: :member
  end

  resources :cameras
  resources :camera_share_requests, path: "share-requests"
  resources :vendors
  patch '/vendors' => 'vendors#update'

  resources :vendor_models, path: :models
  get '/models/load.vendor.model' => 'vendor_models#load_vendor_model'
  patch '/models' => 'vendor_models#update'

  get '/map' => 'dashboard#map'
  get '/kpi' => 'dashboard#kpi'
  get '/no_access' => 'home#no_access'
end
