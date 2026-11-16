class User < ApplicationRecord
  ROLES = %w[customer admin].freeze

  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :role, inclusion: { in: ROLES }

  after_create :assign_default_role
  after_save :save_pending_role

  def self.ransackable_attributes(_auth_object = nil)
    %w[email created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[roles]
  end

  # role หลักของ user (customer หรือ admin) ใช้กับฟอร์ม admin และ JSON API
  def role
    @pending_role || (admin? ? "admin" : "customer")
  end

  # เก็บ role ไว้ก่อนจนกว่าบันทึก user ผ่าน validation เพราะ add_role / remove_role เขียนฐานข้อมูลทันที
  def role=(name)
    @pending_role = name.to_s
  end

  def admin?
    has_role?(:admin)
  end

  private

  def assign_default_role
    add_role(:customer) if @pending_role.nil? && roles.blank?
  end

  def save_pending_role
    return if @pending_role.nil?

    ROLES.each { |name| name == @pending_role ? add_role(name) : remove_role(name) }
    @pending_role = nil
  end
end
