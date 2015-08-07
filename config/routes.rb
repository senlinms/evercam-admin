Rails.application.routes.draw do
  root to: 'dashboard#index'

  devise_options = {
      controllers: {
          registrations: 'registrations'
      }
  }
  devise_for :users, devise_options

  scope '/dashboard' do
    resources :users, only: [:show, :index, :update] do
      get :impersonate, on: :member
    end
  end

  resources :cameras
  resources :vendors
  resources :vendor_models
  get '/vendor_models/load.vendor.model' => 'vendor_models#load_vendor_model'

  get '/map' => 'dashboard#map'
  get '/kpi' => 'dashboard#kpi'
  get '/no_access' => 'home#no_access'
end
