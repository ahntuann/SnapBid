class ListingsController < ApplicationController
  skip_before_action :require_verified_email!, only: [:show]

  def show
    @listing = Listing.published.find(params[:id])
  end
end
