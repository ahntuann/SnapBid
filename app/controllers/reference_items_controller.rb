class ReferenceItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:preview_images]

  def preview_images
    item = ReferenceItem.find(params[:id])
    # Trả về link ảnh Cloudinary
    images = item.images.first(8).map { |img| { url: img.url } }
    render json: { images: images }
  rescue
    render json: { images: [] }
  end
end