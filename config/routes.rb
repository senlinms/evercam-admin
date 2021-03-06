Rails.application.routes.draw do
  resources :archives
  resources :snapshot_extractors
  resources :snapshot_reports
  root to: 'users#index'

  devise_options = {
      controllers: {
          registrations: "registrations",
          passwords: "passwords"
      }
  }
  devise_for :users, devise_options

  resources :users, only: [:show, :index, :update] do
    get :impersonate, on: :member
  end

  resources :cameras do
    collection do
      get "merge"
      get "cleanup"
    end
  end
  resources :camera_share_requests, path: "share-requests"
  resources :snapshots
  resources :vendors
  patch '/vendors' => 'vendors#update'

  resources :vendor_models, path: :models
  get '/models/load.vendor.model' => 'vendor_models#load_vendor_model'
  patch '/models' => 'vendor_models#update'
  delete "/models" => "vendor_models#delete"

  get '/dashboard' => 'dashboard#index'
  get '/map' => 'dashboard#map'
  get "/maps_gardashared" => "dashboard#maps_gardashared"
  get "/maps_construction" => "dashboard#maps_construction"
  get '/kpi' => 'dashboard#kpi'
  get '/no_access' => 'home#no_access'
  get "/cloud_recordings" => "snapshots#cloud_recordings"
  get "/snapmails_history" => "snapmails#history"
  get "/get_history_data" => "snapmails#get_history_data"
  get "/get_email_temaplate" => "snapmails#get_email_temaplate"
  get "/compares" => "compares#index"
  delete "/delete_compare" => "compares#delete"
  get "/snapmails" => "snapmails#index"

  get "/licences/pending_reason" => "licence_reports#pending_reason"
  resources :licence_reports, path: "licences"
  post "/licences/new" => "licence_reports#create"
  delete "/licences/delete" => "licence_reports#destroy"
  patch "/licences/update" => "licence_reports#update"
  post "/licences/auto-renewal" => "licence_reports#auto_renewal"
  get "/load_users" => "users#load_users"
  get "/load_cameras" => "cameras#load_cameras"
  get "/load_camera_shares" => "camera_shares#load_camera_shares"
  get "/intercom/user" => "users#get_intercom"
  get "/timelapse" => "timelapse_report#index"
  get "/snapshot_extractors_list" => "snapshot_extractors#list"
  get "/admins" => "admins#index"
  get "/admins/auto_complete" => "admins#auto_complete"
  post "/admins/new" => "admins#create"
  patch "/admins/make_admin" => "admins#make_admin"
  delete "/admins/delete" => "admins#destroy"
  patch "/admins/update" => "admins#update"

  patch "/multiple_users/update" => "users#update_multiple_users"
  delete "/multiple_share_requests/delete" => "camera_share_requests#delete"

  get "/meta_datas" => "meta_datas#index"
  get "/shares" => "camera_shares#index"
  get "/onvif" => "onvif#index"

  get "/nvr" => "nvrs#index"
  get "/nvr/vh" => "nvrs#vh"
  get "/nvr/snapshot_extractor" => "nvrs#snapshot_extractor"
  get "/check_rtsp_port" => "nvrs#check_rtsp_port"

  get "/intercom/companies" => "intercom_companies#index"
  post "/intercom/companies" => "intercom_companies#create"

  get 'v1/cameras' => 'api#camera_by_contact'
end
