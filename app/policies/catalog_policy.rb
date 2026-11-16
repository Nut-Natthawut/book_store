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

  # Scope = "user คนนี้มองเห็น record ไหนบ้าง" ใช้กับหน้า index ผ่าน policy_scope
  # ร้านเราทุกคนเห็นทุกรายการ จึงคืน scope.all
  # (ถ้ามีกฎเช่น "ซ่อนหนังสือที่ยังไม่วางขาย" ให้แก้ที่นี่ที่เดียว)
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
