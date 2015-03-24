Rails.application.routes.draw do
  # resources :users, only: [:index, :new, :create, :edit, :update]

  devise_for :users

  devise_scope :user do
    get "/login" => "devise/sessions#new"
  end

  # as :user do
  #   get "/login" => "devise/sessions#new"
  # end

  root 'home#index'
  # get "staff", to: 'home#staff', as: :staff
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

          
end
