# ย้าย role จาก column users.role (string) ไปเก็บในตาราง roles / users_roles ของ Rolify
class MoveUserRoleColumnToRolify < ActiveRecord::Migration[8.1]
  def up
    %w[customer admin].each do |name|
      execute <<~SQL
        INSERT INTO roles (name, created_at, updated_at)
        VALUES (#{quote(name)}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      SQL
      execute <<~SQL
        INSERT INTO users_roles (user_id, role_id)
        SELECT users.id, roles.id FROM users
        JOIN roles ON roles.name = users.role AND roles.resource_type IS NULL
        WHERE users.role = #{quote(name)}
      SQL
    end

    remove_column :users, :role
  end

  def down
    add_column :users, :role, :string, null: false, default: "customer"

    execute <<~SQL
      UPDATE users SET role = 'admin'
      WHERE id IN (
        SELECT users_roles.user_id FROM users_roles
        JOIN roles ON roles.id = users_roles.role_id
        WHERE roles.name = 'admin' AND roles.resource_type IS NULL
      )
    SQL
    execute "DELETE FROM users_roles"
    execute "DELETE FROM roles"
  end

  private

  def quote(value)
    connection.quote(value)
  end
end
