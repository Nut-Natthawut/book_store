class Api::V1::UsersController < Api::V1::BaseController
  before_action :require_admin
  before_action :find_user, only: [ :show, :update, :destroy ]
  before_action :prevent_self_demotion, only: :update
  before_action :prevent_self_deletion, only: :destroy

  def index
    render json: User.order(id: :asc).map { |user| user_json(user) }
  end

  def show
    render json: user_json(@user)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: user_json(@user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: user_json(@user)
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

  def prevent_self_demotion
    role = user_params[:role]

    if @user == Current.user && role.present? && role != "admin"
      render json: { errors: [ "ไม่สามารถลดสิทธิ์บัญชีของตัวเองได้" ] }, status: :unprocessable_entity
    end
  end

  def prevent_self_deletion
    if @user == Current.user
      render json: { errors: [ "ไม่สามารถลบบัญชีของตัวเองได้" ] }, status: :unprocessable_entity
    end
  end

  def user_json(user)
    user.as_json(only: [ :id, :email_address, :role ])
  end

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation, :role ])
  end
end
