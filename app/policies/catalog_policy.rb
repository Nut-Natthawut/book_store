# กติกาของข้อมูลในร้าน (Book / Category / Market): ทุกคนดูได้ เฉพาะ admin เพิ่ม แก้ ลบ
class CatalogPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end
end
