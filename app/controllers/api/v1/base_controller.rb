class Api::V1::BaseController < ApplicationController
  before_action :disable_response_cache

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

  def request_authentication
    render json: { errors: [ "กรุณาเข้าสู่ระบบ" ] }, status: :unauthorized
  end

  def require_admin
    unless Current.user&.admin?
      render json: { errors: [ "เฉพาะ admin เท่านั้น" ] }, status: :forbidden
    end
  end

  def disable_response_cache
    response.headers["Cache-Control"] = "no-store"
  end
end
