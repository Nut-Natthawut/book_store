# admin ลบบัญชีตัวเองไม่ได้ (กันไม่ให้ระบบไม่เหลือ admin)
class ActiveAdmin::UserPolicy < ActiveAdmin::ApplicationPolicy
  def destroy?
    admin? && record != user
  end
end
