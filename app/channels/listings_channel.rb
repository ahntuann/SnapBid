class ListingsChannel < ApplicationCable::Channel
  def subscribed
    listing = Listing.find(params[:listing_id])
    stream_for listing
  end

  def unsubscribed
    # cleanup if needed
  end
end
