# ย้ายตาราง users จาก Rails 8 authentication (has_secure_password) ไปใช้ Devise
# รหัสผ่านเดิมเป็น bcrypt เหมือนกัน จึงย้าย column ได้เลย ผู้ใช้เดิมไม่ต้องตั้งรหัสใหม่
class ConvertUsersToDevise < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :email_address, :email
    rename_column :users, :password_digest, :encrypted_password

    change_table :users, bulk: true do |t|
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
    end
    add_index :users, :reset_password_token, unique: true
  end
end
