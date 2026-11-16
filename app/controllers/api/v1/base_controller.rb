class Api::V1::BaseController < ApplicationController
  before_action :disable_response_cache
  before_action :require_login

  rescue_from ActiveRecord::RecordNotFound do
    render json: { errors: [ "ไม่พบข้อมูล" ] }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { errors: [ error.message ] }, status: :bad_request
  end

  rescue_from ActionController::InvalidAuthenticityToken do
    render json: { errors: [ "CSRF token ไม่ถูกต้อง" ] }, status: :unprocessable_entity
  end

  private

  def disable_response_cache
    response.headers["Cache-Control"] = "no-store"
  end

  def require_login
    render json: { errors: [ "กรุณาเข้าสู่ระบบ" ] }, status: :unauthorized unless user_signed_in?
  end

  def require_admin
    unless current_user.admin?
      render json: { errors: [ "เฉพาะ admin เท่านั้น" ] }, status: :forbidden
    end
  end
end
