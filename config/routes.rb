Rails.application.routes.draw do
  get 'atm_ktb_map/index'

  # resources :users, only: [:index, :new, :create, :edit, :update]

  devise_for :users

  #devise_scope :user do
  #  get "/login" => "devise/sessions#new"
  #end

  # as :user do
  #   get "/login" => "devise/sessions#new"
  # end

  root 'home#index'
  
  get "home", to: 'home#index', as: :home

  match 'google_direction', 
          to: 'dsi_respond#google_direction', 
          as: :google_direction,
          via: [:get, :post]

  match 'process_input', 
          to: 'dsi_respond#process_input', 
          as: :process_input,
          via: [:get, :post]
  match 'file_upload', 
          to: 'dsi_respond#file_upload', 
          as: :file_upload,
          via: [:get, :post]
  match 'kml_delete', 
          to: 'dsi_respond#kml_delete', 
          as: :kml_delete,
          via: [:get, :post]
  match 'checkLonLat2', 
          to: 'dsi_respond#checkLonLat2', 
          as: :checkLonLat2,
          via: [:get, :post]
  match 'checkLonLatDD', 
          to: 'dsi_respond#checkLonLatDD', 
          as: :checkLonLatDD,
          via: [:get, :post]
  match 'checkUTM', 
          to: 'dsi_respond#checkUTM', 
          as: :checkUTM,
          via: [:get, :post]
  match 'checkUTMIndian', 
          to: 'dsi_respond#checkUTMIndian', 
          as: :checkUTMIndian,
          via: [:get, :post]
  match 'search_googlex', 
          to: 'dsi_respond#search_googlex', 
          as: :search_googlex,
          via: [:get, :post]
  match 'getPolygonWKT', 
          to: 'dsi_respond#getPolygonWKT', 
          as: :getPolygonWKT,
          via: [:get, :post]   
  match 'file_upload_xls', 
          to: 'dsi_respond#file_upload_xls', 
          as: :file_upload_xls,
          via: [:get, :post]   
  match 'check_forest_info', 
          to: 'dsi_respond#check_forest_info', 
          as: :check_forest_info,
          via: [:get, :post]
  match 'get_lonlat_from_ip', 
          to: 'dsi_respond#get_lonlat_from_ip', 
          as: :get_lonlat_from_ip,
          via: [:get, :post]

  match 'atm_ktb', 
          to: 'dsi_respond#atm_ktb', 
          as: :atm_ktb,
          via: [:get, :post]
  match 'atm_ktb_map', 
          to: 'atm_ktb_map#index', 
          as: :atm_ktb_map,
          via: [:get]

  match 'atm_ktb_layer',
        to: 'atm#ktb',
        as: :atm_ktb_layer,
        via: [:get, :post]

  match 'atm_kbank_layer',
        to: 'atm#kbank',
        as: :atm_kbank_layer,
        via: [:get, :post]

end
