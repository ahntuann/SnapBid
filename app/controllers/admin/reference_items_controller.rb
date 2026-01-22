class Admin::ReferenceItemsController < Admin::BaseController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @items = ReferenceItem.all.order(created_at: :desc)
  end

  def new
    @item = ReferenceItem.new
  end

  def create
    @item = ReferenceItem.new(item_params)
    if @item.save
      redirect_to admin_reference_items_path, notice: "Đã tạo túi mẫu thành công!"
    else
      render :new
    end
  end

  def edit
    # Rails tự động tìm view 'edit.html.erb'
  end

  def update
    # Logic: Nếu admin up ảnh mới -> Xóa sạch ảnh cũ để thay thế (đảm bảo đúng thứ tự 8 ảnh)
    if params[:reference_item][:images].present?
      @item.images.purge # Xóa ảnh cũ
    end

    if @item.update(item_params)
      redirect_to admin_reference_items_path, notice: "Đã cập nhật túi mẫu!"
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    redirect_to admin_reference_items_path, notice: "Đã xoá túi mẫu."
  end

  private

  def set_item
    @item = ReferenceItem.find(params[:id])
  end

  def item_params
    params.require(:reference_item).permit(:name, :brand, :description, images: [])
  end
end