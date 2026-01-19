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

  def edit; end

  def update
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