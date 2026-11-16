class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def new
    @user = authorize User.new
  end

  def create
    @user = authorize User.new(user_params)

    if @user.save
      redirect_to new_user_path, notice: "สร้างผู้ใช้แล้ว"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :email, :password, :password_confirmation, :role ])
  end
end
