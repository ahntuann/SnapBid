Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check

  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "home#index"
  get "/help", to: "help#index", as: :help
  get "/help/selling", to: "help#selling", as: :help_selling
  resources :listings, only: [:show]

  # API Routes
  # namespace :api do
  #   namespace :v1 do
  #     resources :listings, only: [:index, :show]
  #     post '/login', to: 'users#login'
  #     get '/profile', to: 'users#profile'
  #   end
  # end

  namespace :admin do
    resource :settings, only: %i[show edit update]
    resources :reference_items
  end

  # resource :otp_session, only: %i[new create] do
  #   get :verify
  #   post :confirm
  # end

  resource :email_verification, only: %i[new create] do
    post :resend
  end

  resources :listings, only: [:index, :show] do
    resources :bids, only: [:create]
    post :buy_now, on: :member
  end

  resources :orders, only: [:index, :show, :update] do
    member do
      post :mark_paid  # buyer bấm "Tôi đã chuyển tiền"
    end
  end

  # namespace :admin do
  #   resources :orders, only: [:index, :show] do
  #     member do
  #       post :confirm_paid  # admin bấm "Đã nhận tiền"
  #     end
  #   end
  # end

  namespace :admin do
    root to: "dashboard#index"
    resources :listings, only: %i[index show] do
      member do
        patch :block
        patch :unblock
      end
    end
    resources :users, only: %i[index show]
    resources :categories
    resources :orders, only: %i[index show] do
      member do
        post :confirm_paid  # admin bấm "Đã nhận tiền"
        patch :cancel
      end
    end
  end

  resources :reference_items, only: [] do
    member do
      get :preview_images
    end
  end

  devise_scope :user do
    get  "/admin/login",  to: "admin/sessions#new",     as: :admin_login
    post "/admin/login",  to: "admin/sessions#create"
    delete "/admin/logout", to: "admin/sessions#destroy", as: :admin_logout
  end

  namespace :seller do
    resources :listings do
      post :submit_ai_verification, on: :member
    end
  end

  resources :notifications, only: [:index] do
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end

  resource :profile, only: %i[show edit update] do
    delete :destroy_avatar, on: :collection
  end

  get "/my-bids", to: "bids#mine", as: :my_bids
end
