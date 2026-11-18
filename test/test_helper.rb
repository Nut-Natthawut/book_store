# SimpleCov ต้องเริ่มก่อนโหลดโค้ดของแอป ไม่งั้นไฟล์ที่โหลดไปแล้วจะไม่ถูกนับ coverage
# profile "rails" รวมผลจาก worker ของ parallelize ให้อัตโนมัติ
require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # สร้าง user สำหรับ test ด้วยรหัสผ่านสุ่ม (ไม่ hardcode รหัสผ่าน)
    def create_user(role: "customer", email: "#{role}-#{SecureRandom.hex(4)}@example.com")
      User.create!(email: email, password: SecureRandom.hex(12), role: role)
    end

    def create_category(name: "Category #{SecureRandom.hex(4)}")
      Category.create!(name: name)
    end

    # สร้างหนังสือที่ผ่าน validation แล้ว ส่ง attribute ที่ต้องการเปลี่ยนมาทับได้
    def create_book(**attrs)
      Book.create!({ title: "Book #{SecureRandom.hex(4)}", author: "Author", description: "Description",
                     price: 100, category: attrs[:category] || create_category }.merge(attrs))
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # ได้ sign_in / sign_out
end
