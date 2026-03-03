class WalletsController < ApplicationController
  before_action :authenticate_user!

  def show
    @coin_balance    = current_user.coin_balance
    @deposit_ref     = current_user.deposit_ref
    @exchange_rate   = User::COIN_EXCHANGE_RATE
    @recent_deposits = current_user.coin_deposits.order(created_at: :desc).limit(10)
  end
end
