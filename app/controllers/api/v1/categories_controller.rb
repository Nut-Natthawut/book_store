class Api::V1::CategoriesController < Api::V1::BaseController
  before_action :require_admin, except: [ :index, :show ]
  before_action :find_category, only: [ :show, :update, :destroy ]

  def index
    render json: Category.order(id: :asc).map { |category| category_json(category) }
  end

  def show
    render json: category_json(@category)
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      render json: category_json(@category), status: :created
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: category_json(@category)
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

  def category_json(category)
    category.as_json(only: [ :id, :name ])
  end

  def category_params
    params.expect(category: [ :name ])
  end
end
