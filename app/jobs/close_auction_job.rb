class CloseAuctionJob < ApplicationJob
  queue_as :default

  def perform(listing_id)
    Rails.logger.info("[CloseAuctionJob] start listing_id=#{listing_id}")

    listing = Listing.find_by(id: listing_id)
    if listing.nil?
      Rails.logger.info("[CloseAuctionJob] listing not found id=#{listing_id}")
      return
    end

    result = AuctionCloseService.call!(listing: listing)

    Rails.logger.info("[CloseAuctionJob] done listing_id=#{listing_id} status=#{result.status} order_id=#{result.order&.id} error=#{result.error}")
  end
end
