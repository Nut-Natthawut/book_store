class Api::V1::UsersController < Api::V1::BaseController
  before_action :require_admin
  before_action :find_user, only: [ :show, :update, :destroy ]

  def index
    render json: User.order(id: :asc).as_json(only: [ :id, :email_address, :role ])
  end

  def show
    render json: @user.as_json(only: [ :id, :email_address, :role ])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user.as_json(only: [ :id, :email_address, :role ]), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user.as_json(only: [ :id, :email_address, :role ])
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
    head :no_content
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation, :role ])
  end
end
