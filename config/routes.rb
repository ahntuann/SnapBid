Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  mount ActionCable.server => "/cable"

  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

   root "home#index"
   resources :listings, only: [:show]

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
    resources :listings, only: %i[index show edit update]
    resources :users, only: %i[index show edit update]
    resources :orders, only: %i[index show] do
      member do
        post :confirm_paid  # admin bấm "Đã nhận tiền"
      end
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

  get "/my-bids", to: "bids#mine", as: :my_bids
end
