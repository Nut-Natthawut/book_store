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
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # ได้ sign_in / sign_out
end
