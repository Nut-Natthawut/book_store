class Api::V1::SessionsController < Api::V1::BaseController
  allow_unauthenticated_access only: [ :new, :create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { render json: { errors: [ "ลองเข้าสู่ระบบใหม่ภายหลัง" ] }, status: :too_many_requests }

  def new
    render json: { csrf_token: form_authenticity_token }
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user
      start_new_session_for user
      render json: {
        user: user.as_json(only: [ :id, :email_address, :role ]),
        csrf_token: form_authenticity_token
      }
    else
      render json: { errors: [ "อีเมลหรือรหัสผ่านไม่ถูกต้อง" ] }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    head :no_content
  end
end
