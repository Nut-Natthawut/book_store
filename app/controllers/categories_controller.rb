class CategoriesController < ApplicationController
  before_action :require_admin
  before_action :find_category, only: [ :edit, :update, :destroy ]

  def index
    @categories = Category.order(:name)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to categories_path, notice: "เพิ่มหมวดหมู่แล้ว"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "แก้ไขหมวดหมู่แล้ว", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to categories_path, notice: "ลบหมวดหมู่แล้ว", status: :see_other
    else
      redirect_to categories_path, alert: "ลบหมวดหมู่นี้ไม่ได้ เพราะยังมีหนังสืออยู่", status: :see_other
    end
  end

  private

  def find_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
