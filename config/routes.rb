Rails.application.routes.draw do
  resources :albums, except: [:show] do
    resources :photos, except: [:show, :new, :create], shallow: true do
      member do
        get :download
      end
    end
    member do
      patch :update_cover_photo
      get :new_photos
      post :create_photos
    end
    post :update_photo_position
  end
  resources :users
  resources :sessions
  
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#destroy'
  
  root 'albums#index'
end
