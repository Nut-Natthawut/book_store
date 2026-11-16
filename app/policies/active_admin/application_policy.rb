# Policy เริ่มต้นของหลังบ้าน (/admin): admin ทำได้ทุกอย่าง คนอื่นทำไม่ได้เลย
class ActiveAdmin::ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = admin?
  def show? = admin?
  def new? = create?
  def create? = admin?
  def edit? = update?
  def update? = admin?
  def destroy? = admin?
  def destroy_all? = admin? # batch action "Delete Selected"

  private

  def admin?
    user&.admin? || false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @user&.admin? ? @scope.all : @scope.none
    end
  end
end
