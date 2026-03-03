class CoinTransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @transactions = current_user.coin_transactions.order(created_at: :desc).page(params[:page]).per(20)
  end
end
