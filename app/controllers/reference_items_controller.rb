class ReferenceItemsController < ApplicationController
  # Cho phép gọi API này mà không cần login (hoặc cần login tuỳ bạn)
  # skip_before_action :authenticate_user!, only: [:preview_images]

  def preview_images
    item = ReferenceItem.find(params[:id])
    
    # Lấy 8 ảnh từ Cloudinary trả về cho giao diện
    # Cloudinary lưu ảnh theo thứ tự upload, nên admin up đúng thứ tự thì nó sẽ ra đúng
    images = item.images.first(8).map do |img| 
      { 
        url: img.url, # Link ảnh Cloudinary
        id: img.id 
      }
    end

    render json: { images: images }
  rescue ActiveRecord::RecordNotFound
    render json: { images: [] }, status: 404
  end
end