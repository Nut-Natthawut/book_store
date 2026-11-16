ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :role

  includes :roles

  index do
    selectable_column
    id_column
    column :email
    column(:roles) { |user| user.roles.map(&:name).join(", ") }
    column :created_at
    actions
  end

  filter :email
  filter :roles, collection: -> { Role.order(:name) }
  filter :created_at

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :email
      f.input :password, hint: ("เว้นว่างถ้าไม่ต้องการเปลี่ยน" if f.object.persisted?)
      f.input :password_confirmation
      f.input :role, as: :select, collection: User::ROLES, include_blank: false
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :role
      row :created_at
    end
  end

  controller do
    def update
      # แก้ user ได้โดยไม่ต้องกรอกรหัสผ่านใหม่ทุกครั้ง
      if params[:user][:password].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      # admin ลดสิทธิ์ตัวเองไม่ได้ (กันไม่ให้ระบบไม่เหลือ admin)
      if resource == current_user && params[:user][:role].present? && params[:user][:role] != "admin"
        return redirect_to edit_resource_path, alert: "ไม่สามารถลดสิทธิ์บัญชีของตัวเองได้"
      end

      super
    end
  end
end
