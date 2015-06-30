Rails.application.routes.draw do
  root to: 'dashboard#index'

  devise_for :users

  scope '/admin' do
    resources :users, only: [:show, :index, :update] do
      get :impersonate, on: :member
    end
  end

  resources :cameras
  resources :vendors
  resources :vendor_models

  get '/map' => 'dashboard#map'
  get '/kpi' => 'dashboard#kpi'
end
