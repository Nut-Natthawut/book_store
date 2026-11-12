class Api::V1::CategoriesController < Api::V1::BaseController
  before_action :require_admin, except: [ :index, :show ]
  before_action :find_category, only: [ :show, :update, :destroy ]

  def index
    render json: Category.order(id: :asc).as_json(only: [ :id, :name ])
  end

  def show
    render json: @category.as_json(only: [ :id, :name ])
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category.as_json(only: [ :id, :name ]), status: :created
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category.as_json(only: [ :id, :name ])
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      head :no_content
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.expect(category: [ :name ])
  end
end
