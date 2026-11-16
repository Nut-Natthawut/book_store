class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # ใช้ main_app เพื่อให้ทำงานได้ทั้งใน controller ของแอปและของ ActiveAdmin
  def user_not_authorized(_exception = nil)
    redirect_back_or_to main_app.root_path, alert: "คุณไม่มีสิทธิ์ทำรายการนี้"
  end
end
