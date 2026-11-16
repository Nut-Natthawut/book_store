class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :require_login, only: [ :new, :create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render json: { errors: [ "ลองเข้าสู่ระบบใหม่ภายหลัง" ] }, status: :too_many_requests }

  def new
    render json: { csrf_token: form_authenticity_token }
  end

  def create
    user = User.find_for_authentication(email: params[:email])

    if user&.valid_password?(params[:password])
      sign_in(user)
      render json: {
        user: user.as_json(only: [ :id, :email ], methods: :role),
        csrf_token: form_authenticity_token
      }
    else
      render json: { errors: [ "อีเมลหรือรหัสผ่านไม่ถูกต้อง" ] }, status: :unauthorized
    end
  end

  def destroy
    sign_out(current_user)
    head :no_content
  end
end
