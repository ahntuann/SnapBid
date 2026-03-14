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
  get "/help/selling",  to: "help#selling",  as: :help_selling
  get "/help/buying",   to: "help#buying",   as: :help_buying
  get "/help/wallet",   to: "help#wallet",   as: :help_wallet
  get "/help/account",  to: "help#account",  as: :help_account
  get "/help/policies", to: "help#policies", as: :help_policies
  get "/help/contact",  to: "help#contact",  as: :help_contact
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
    resource :watchlist, only: [:create, :destroy]
    post :buy_now, on: :member
  end

  resources :orders, only: [:index, :show, :update] do
    member do
      post :mark_paid        # kept for backward compat
      post :pay_with_coins   # thanh toán bằng SnapBid Coin
      get  :status           # polling fallback – trả JSON {status, paid, ...}
    end
  end

  resource :wallet, only: [:show]
  resources :withdrawal_requests, only: [:index, :new, :create]
  resources :coin_transactions, only: [:index]

  # namespace :admin do
  #   resources :orders, only: [:index, :show] do
  #     member do
  #       post :confirm_paid  # admin bấm "Đã nhận tiền"
  #     end
  #   end
  # end

  namespace :admin do
    root to: "dashboard#index"
    get "test_webhook", to: "dashboard#test_webhook", as: :test_webhook
    post "send_test_webhook", to: "dashboard#send_test_webhook", as: :send_test_webhook
    resources :listings, only: %i[index show] do
      member do
        patch :block
        patch :unblock
      end
    end
    resources :users, only: %i[index show] do
      post :adjust_coins, on: :member
      post :lock_account, on: :member
      post :unlock_account, on: :member
    end
    resources :categories
    resources :orders, only: %i[index show] do
      member do
        post :confirm_paid  # admin bấm "Đã nhận tiền"
        patch :cancel
      end
    end
    resources :withdrawal_requests, only: %i[index show] do
      member do
        post :approve
        post :reject
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
    get :reports, to: "reports#index"
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
    get :edit_shop, on: :collection
    patch :update_shop, on: :collection
    delete :destroy_avatar, on: :collection
  end

  resources :sellers, only: [:show]

  get "/my-bids", to: "bids#mine", as: :my_bids

  # SePay webhook – SePay sẽ POST vào URL này khi nhận được chuyển khoản
  post "/webhooks/sepay", to: "webhooks/sepay#create", as: :sepay_webhook
end
