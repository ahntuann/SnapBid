class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.ordered
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: "Đã tạo danh mục."
    else
      flash.now[:alert] = @category.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Đã cập nhật danh mục."
    else
      flash.now[:alert] = @category.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: "Đã xoá danh mục."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_categories_path, alert: "Không thể xoá vì đang có listing dùng danh mục này."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
