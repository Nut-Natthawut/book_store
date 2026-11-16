# Devise + Rolify + Pundit + ActiveAdmin ใน Book Store

เอกสารนี้อธิบายว่าเพิ่ม 4 gem เข้ามาในโปรเจกต์อย่างไร แต่ละขั้นแก้ไฟล์ไหน เพราะอะไร และลองทดสอบได้อย่างไร
วิธีติดตั้งและเปิดโปรเจกต์อยู่ใน [README](../README.md)

- [ภาพรวม](#ภาพรวม)
- [Task 1: Devise — ล็อกอิน](#task-1-devise--ล็อกอิน)
- [Task 2: Rolify — role ของ user](#task-2-rolify--role-ของ-user)
- [Task 3: Pundit — สิทธิ์](#task-3-pundit--สิทธิ์)
- [Task 4: ActiveAdmin v4 — หลังบ้าน](#task-4-activeadmin-v4--หลังบ้าน)
- [ดู diff ทีละ task](#ดู-diff-ทีละ-task)

## ภาพรวม

```
Request ─▶ Devise ─────────▶ Pundit policy ─────────▶ Rolify
           "คุณคือใคร?"       "ทำสิ่งนี้ได้ไหม?"        current_user.has_role?(:admin)
           ได้ current_user   ได้ → ทำต่อ / ไม่ได้ → redirect หรือ 403
                                    │
                 ┌──────────────────┼──────────────────┐
                 ▼                  ▼                  ▼
           หน้าร้าน /books      JSON API /api/v1     หลังบ้าน /admin (ActiveAdmin)
           BookPolicy           BookPolicy ฯลฯ       ActiveAdmin::ApplicationPolicy
```

แต่ละ gem พึ่ง gem ก่อนหน้า จึงทำตามลำดับ 1 → 2 → 3 → 4 และแยกเป็น 1 commit ต่อ 1 gem

**ความต่างจากโปรเจกต์ตัวอย่างทั่วไป:** Book Store มีระบบล็อกอินของ Rails 8 (`has_secure_password` + ตาราง `sessions`),
column `users.role` และหน้า `/admin` ที่เขียนเองอยู่ก่อนแล้ว งานนี้จึงเป็นการ **เอาของเดิมออกแล้วใส่ gem แทน** โดยไม่ให้ข้อมูลเดิมหาย

---

## Task 1: Devise — ล็อกอิน

**เป้าหมาย:** ล็อกอิน / สมัครสมาชิก / ลืมรหัสผ่าน / แก้บัญชี ด้วย Devise ใช้ทั้งหน้าเว็บและ API

### 1.1 ติดตั้ง

```bash
# Gemfile: gem "devise", "~> 5.0"
bundle install
bin/rails g devise:install
```

ได้ `config/initializers/devise.rb` แก้ 2 จุด:

```ruby
config.mailer_sender = "no-reply@bookstore.local"
config.password_length = 8..72 # bcrypt ใช้แค่ 72 bytes แรก
```

### 1.2 ย้ายตาราง users ไปใช้ Devise (ไม่สร้างใหม่)

ปกติจะใช้ `bin/rails g devise User` แต่เรามีตาราง `users` และบัญชีอยู่แล้ว จึงเขียน migration **เปลี่ยนชื่อ column** แทน
(`db/migrate/20261116080422_convert_users_to_devise.rb`):

```ruby
rename_column :users, :email_address, :email                # Devise ใช้ชื่อ email
rename_column :users, :password_digest, :encrypted_password # Devise ใช้ชื่อนี้
# column ที่ module recoverable / rememberable ต้องใช้
t.string   :reset_password_token
t.datetime :reset_password_sent_at
t.datetime :remember_created_at
```

> 💡 `has_secure_password` กับ Devise เข้ารหัสด้วย **bcrypt เหมือนกัน** แค่ย้าย column รหัสผ่านเดิมก็ใช้ต่อได้ ผู้ใช้เดิมไม่ต้องตั้งรหัสใหม่

`drop_sessions.rb` ลบตาราง `sessions` เพราะ Devise เก็บการล็อกอินไว้ใน cookie session อยู่แล้ว

`app/models/user.rb`:

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :validatable
```

### 1.3 บังคับล็อกอินใน controller

ลบไฟล์ระบบเดิม: `concerns/authentication.rb`, `sessions_controller.rb`, `models/session.rb`, `models/current.rb`

ระบบเดิม **บังคับล็อกอินทุกหน้า** แล้วยกเว้นบางหน้า ส่วน Devise ใช้วิธีกลับกัน คือ **ใส่เฉพาะหน้าที่ต้องล็อกอิน**:

```ruby
# app/controllers/books_controller.rb
before_action :authenticate_user!, except: [ :index, :show ]
```

| ระบบเดิม | Devise |
|---|---|
| `authenticated?` | `user_signed_in?` |
| `Current.user` | `current_user` |
| `new_session_path` | `new_user_session_path` |
| `session_path` (DELETE) | `destroy_user_session_path` |

### 1.4 View

- navbar ใน `app/views/books/index.html.erb` มีปุ่ม เข้าสู่ระบบ / สมัครสมาชิก / บัญชีของฉัน / ออกจากระบบ
  (ออกจากระบบต้องเป็น `button_to ... method: :delete` ถ้าใช้ `link_to` จะส่ง GET แล้ว error)
- `bin/rails g devise:views -v sessions registrations passwords` แล้วแปลเป็นภาษาไทยใน `app/views/devise/`

### 1.5 API และอีเมล

- `app/controllers/api/v1/sessions_controller.rb` ล็อกอินด้วย `user.valid_password?` แล้ว `sign_in(user)` ใช้ cookie เดียวกับหน้าเว็บ
  request ส่ง `email` (เดิม `email_address`)
- อีเมลลืมรหัสผ่านถูกส่งไปที่ Mailpit (`config/environments/development.rb`) ดูได้ที่ http://localhost:8025

### 1.6 Seed ไม่ hardcode รหัสผ่าน

`db/seeds.rb` อ่านอีเมล/รหัสผ่านจาก `.env` (`ENV.fetch("ADMIN_PASSWORD")`) ซึ่งไม่ถูก commit มี `.env.example` เป็นตัวอย่าง
gem `dotenv` โหลด `.env` ให้ตอนรัน `bin/dev`

### ✅ ทดสอบ Devise

1. Guest เข้า http://localhost:3000/books/new → ถูกส่งไปหน้าเข้าสู่ระบบ
2. กด "สมัครสมาชิก" → สมัครแล้วล็อกอินอัตโนมัติ เห็นอีเมลใน navbar
3. กด "บัญชีของฉัน" → เปลี่ยนรหัสผ่านได้ (ต้องกรอกรหัสปัจจุบัน)
4. ออกจากระบบ → กด "ลืมรหัสผ่าน?" ใส่อีเมล → เปิด http://localhost:8025 จะเห็นอีเมลตั้งรหัสใหม่

---

## Task 2: Rolify — role ของ user

**เป้าหมาย:** เก็บ role (`customer` / `admin`) ในตารางของ Rolify แทน column `users.role` user ใหม่เป็น `customer` อัตโนมัติ

### 2.1 ติดตั้ง

```bash
# Gemfile: gem "rolify", "~> 6.0"
bundle install
bin/rails g rolify Role User
```

ได้ `app/models/role.rb`, `config/initializers/rolify.rb` และ migration สร้างตาราง `roles` กับตารางเชื่อม `users_roles`
และเพิ่มบรรทัด `rolify` ใน `User`

### 2.2 ย้าย role เดิมเข้า Rolify

`db/migrate/20261116080708_move_user_role_column_to_rolify.rb`:

1. สร้าง role `customer` และ `admin` ในตาราง `roles`
2. ผูก user แต่ละคนกับ role ตามค่าใน `users.role` เดิม
3. ลบ column `users.role`

migration นี้ย้อนกลับได้ (`bin/rails db:rollback`) จะคืนค่าใน column ให้

`config/initializers/rolify.rb` ตั้ง `remove_role_if_empty = false` ให้แถว role ยังอยู่แม้ไม่มีใครถือ role นั้น

### 2.3 User model

```ruby
class User < ApplicationRecord
  ROLES = %w[customer admin].freeze

  rolify
  after_create :assign_default_role # user ใหม่ได้ role customer

  def admin?
    has_role?(:admin)
  end

  # role= เก็บค่าไว้ก่อน แล้วค่อย add_role / remove_role หลังบันทึกผ่าน validation
  # เพราะ add_role / remove_role เขียนฐานข้อมูลทันที ถ้า validation ไม่ผ่านจะได้ไม่เปลี่ยน role ไปแล้ว
  def role=(name) ... end
  def role ... end # คืน "admin" หรือ "customer"
end
```

`role` / `role=` มีไว้ให้ฟอร์ม admin และ JSON API ใช้ `"role": "admin"` ได้เหมือนเดิม API จึงไม่ต้องเปลี่ยนรูปแบบ

### ✅ ทดสอบ Rolify

```bash
docker compose exec web bin/rails console   # หรือ bin/rails console
```

```ruby
user = User.find_by(email: "user@example.com")
user.roles.pluck(:name)     # => ["customer"]
user.has_role?(:admin)      # => false
user.add_role(:admin)       # เพิ่ม role
user.admin?                 # => true
user.remove_role(:admin)
User.with_role(:admin).pluck(:email)
```

หรือสมัครบัญชีใหม่ที่หน้าเว็บ แล้วเช็ค `User.last.roles.pluck(:name)` จะได้ `["customer"]`

---

## Task 3: Pundit — สิทธิ์

**เป้าหมาย:** ย้ายการเช็คสิทธิ์จาก `require_admin` ที่กระจายอยู่ใน controller มาไว้ใน policy class ที่เดียว ใช้ทั้งหน้าเว็บ, view และ API

### 3.1 ติดตั้ง

```bash
# Gemfile: gem "pundit", "~> 2.5"
bundle install
bin/rails g pundit:install   # ได้ app/policies/application_policy.rb
```

### 3.2 Policy

1 model = 1 policy แต่ละ method ตอบ `true` / `false`

| ไฟล์ | กติกา |
|---|---|
| `application_policy.rb` | ค่าเริ่มต้นปฏิเสธทุกอย่าง มี helper `admin?` |
| `catalog_policy.rb` | ทุกคนดูได้ (`index?`, `show?`) เฉพาะ admin `create?` / `update?` / `destroy?` |
| `book_policy.rb`, `category_policy.rb`, `market_policy.rb` | สืบทอด `CatalogPolicy` (กติกาเหมือนกัน) |
| `user_policy.rb` | ทุก action เฉพาะ admin |

> 💡 `new?` เรียก `create?` และ `edit?` เรียก `update?` ให้อยู่แล้ว เขียนแค่ `create?` / `update?` ก็พอ

### 3.3 Controller

`app/controllers/application_controller.rb`:

```ruby
include Pundit::Authorization
rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

def user_not_authorized(_exception = nil)
  redirect_back_or_to main_app.root_path, alert: "คุณไม่มีสิทธิ์ทำรายการนี้"
end
```

`app/controllers/books_controller.rb`:

```ruby
after_action :verify_authorized   # กันลืม: action ไหนไม่เรียก authorize จะ error

def new
  @book = authorize Book.new       # เรียก BookPolicy#new? ถ้าได้ false → NotAuthorizedError
end

def find_book
  @book = authorize Book.find(params[:id]) # ใช้ชื่อ action อัตโนมัติ: edit → edit?, destroy → destroy?
end
```

> ⚠️ ใส่ `verify_authorized` ไว้ใน controller ของเราเท่านั้น ห้ามใส่ใน `ApplicationController`
> เพราะ controller ของ Devise และ ActiveAdmin สืบทอดจากมันและไม่ได้เรียก `authorize`

**API** (`app/controllers/api/v1/`) เรียก `before_action { authorize Book }` ตั้งแต่ต้น action ส่วน `base_controller.rb`
แปลง `Pundit::NotAuthorizedError` เป็น `403` JSON (ไม่ redirect)

### 3.4 View

ซ่อนปุ่มตามสิทธิ์ (`app/views/books/_actions.html.erb`, `index.html.erb`):

```erb
<% if policy(book).edit? %>
  <%= link_to "แก้ไขหนังสือ", edit_book_path(book) %>
<% end %>
```

> ⚠️ ซ่อนปุ่มเป็นแค่ UX ความปลอดภัยจริงอยู่ที่ `authorize` ใน controller (คนพิมพ์ URL เองได้เสมอ)

### ✅ ทดสอบ Pundit

1. **Guest**: ไม่เห็นปุ่ม เพิ่ม/แก้ไข/ลบหนังสือ
2. **Customer**: ล็อกอินแล้วพิมพ์ URL http://localhost:3000/books/1/edit เอง → redirect พร้อม "คุณไม่มีสิทธิ์ทำรายการนี้"
3. **Admin**: เห็นปุ่มและแก้ไข/ลบหนังสือได้
4. รัน test ของ policy: `bin/rails test test/policies`

---

## Task 4: ActiveAdmin v4 — หลังบ้าน

**เป้าหมาย:** แทนหน้า `/admin`, categories, markets, users ที่เขียนเอง ด้วย ActiveAdmin เข้าได้เฉพาะ admin

ใช้ `User` ตัวเดียวกับหน้าบ้าน (ไม่สร้าง `AdminUser`) ล็อกอินด้วย Devise และเช็คสิทธิ์ด้วย Pundit

### 4.1 ติดตั้ง

```bash
# Gemfile:
#   gem "activeadmin", "4.0.0.beta23"   # v4 ยังเป็น beta ต้องระบุเวอร์ชันตรง ๆ
#   gem "importmap-rails"               # ActiveAdmin โหลด JS ของตัวเองผ่าน importmap (แอปยังใช้ esbuild)
bundle install
bin/rails g active_admin:install --skip-users --skip-comments
yarn add @activeadmin/activeadmin@4.0.0-beta23   # ต้องตรงเวอร์ชันกับ gem
```

`config/routes.rb` ต้องมี `devise_for :users` **ก่อน** `ActiveAdmin.routes(self)`

### 4.2 CSS ของ admin

ActiveAdmin v4 ใช้ Tailwind จึง build CSS แยกจากหน้าบ้าน:

| ไฟล์ | แก้อะไร |
|---|---|
| `package.json` | `build:css:app` + `build:css:admin` (และ `build:css` รวมทั้งสอง) |
| `Procfile.dev` | เพิ่ม process `css_admin` ให้ `bin/dev` watch CSS ของ admin |
| `tailwind-active_admin.config.mjs` | เปลี่ยนนามสกุลจาก `.js` เป็น `.mjs` กัน warning เรื่อง ES module |
| `app/views/layouts/application.html.erb` | `stylesheet_link_tag :app` → `"application"` ไม่ให้ CSS ของ admin มาปนหน้าบ้าน |

### 4.3 เชื่อม Devise + Pundit

`config/initializers/active_admin.rb`:

```ruby
config.authentication_method   = :authenticate_user!          # Devise
config.current_user_method     = :current_user
config.logout_link_path        = :destroy_user_session_path

config.authorization_adapter   = ActiveAdmin::PunditAdapter
config.pundit_policy_namespace = :active_admin                # หา ActiveAdmin::BookPolicy ก่อน
config.pundit_default_policy   = "ActiveAdmin::ApplicationPolicy"
config.on_unauthorized_access  = ->(_controller, exception) { user_not_authorized(exception) }
```

> **ทำไมต้องแยก namespace?** `BookPolicy` ของหน้าบ้านอนุญาต `index?` ให้ทุกคน
> ถ้า ActiveAdmin ใช้ policy เดียวกัน customer จะเปิด `/admin/books` ได้

`app/policies/active_admin/application_policy.rb` — admin ทำได้ทุกอย่าง คนอื่นทำไม่ได้เลย (รวม Dashboard)
`app/policies/active_admin/user_policy.rb` — admin ลบบัญชีตัวเองไม่ได้

### 4.4 Resource

| ไฟล์ | หน้า |
|---|---|
| `app/admin/dashboard.rb` | จำนวน Books / Categories / Markets / Users และหนังสือล่าสุด |
| `app/admin/books.rb` | CRUD หนังสือ เลือกหมวดและร้าน (checkbox) กรองตามชื่อ ผู้เขียน หมวด ร้าน ราคา |
| `app/admin/categories.rb` | CRUD หมวด ลบหมวดที่ยังมีหนังสือไม่ได้ (แสดงเหตุผล) |
| `app/admin/markets.rb` | CRUD ร้าน |
| `app/admin/users.rb` | CRUD ผู้ใช้ เลือก role, เว้นรหัสผ่านว่างได้ตอนแก้, ลดสิทธิ์ตัวเองไม่ได้ |

### 4.5 Ransack

filter ของ ActiveAdmin ใช้ Ransack ซึ่ง **บังคับ** ให้ประกาศว่า column ไหนค้นหาได้ ใส่ `ransackable_attributes` /
`ransackable_associations` ไว้ใน `Book`, `Category`, `Market`, `BookMarket`, `Role`, `User`
(ห้ามใส่ `encrypted_password` / `reset_password_token`)

### ✅ ทดสอบ ActiveAdmin

1. Guest เปิด http://localhost:3000/admin → ถูกส่งไปหน้าเข้าสู่ระบบ
2. Customer เปิด `/admin` → redirect กลับพร้อม "คุณไม่มีสิทธิ์ทำรายการนี้"
3. Admin → กด "หน้าจัดการ Admin" เห็น Dashboard มีสไตล์ สลับ dark mode ได้ (ไอคอนพระอาทิตย์มุมขวาบน)
4. Books → ลองแก้ไข เลือกร้าน และใช้ filter Markets / Category
5. Categories → ลองลบหมวดที่มีหนังสือ จะลบไม่ได้และขึ้นเหตุผล
6. Users → เปลี่ยน role ของ `user@example.com` เป็น admin → ล็อกอินบัญชีนั้นจะเข้า `/admin` ได้ทันที
7. Users → บัญชีที่ล็อกอินอยู่ไม่มีปุ่ม Delete และเปลี่ยนตัวเองเป็น customer ไม่ได้
8. Logout (เมนูรูปคนมุมขวาบน) → กลับหน้าร้าน

---

## ดู diff ทีละ task

```bash
git log --oneline main..gem
```

| Task | Commit message |
|---|---|
| 1 Devise | `Replace Rails 8 authentication with Devise` |
| 2 Rolify | `Move user roles to Rolify` |
| 3 Pundit | `Authorize with Pundit policies` |
| — | `Add Docker Compose development environment` |
| 4 ActiveAdmin | `Replace hand-written admin pages with ActiveAdmin v4` |

```bash
git show <commit> --stat                 # ไฟล์ที่แก้ใน commit นั้น
git show <commit> -- app/models/user.rb  # diff เฉพาะไฟล์
```

Test ของแต่ละส่วน (`bin/rails test` หรือ `docker compose exec web bin/rails test`):

| ไฟล์ | ทดสอบอะไร |
|---|---|
| `test/models/user_test.rb` | role เริ่มต้น, เปลี่ยน role, role ผิดไม่ทำให้ role เดิมหาย (Rolify) |
| `test/policies/` | กติกาของ `BookPolicy` และ `UserPolicy` (Pundit) |
| `test/integration/books_authorization_test.rb` | guest / customer / admin ในหน้าร้าน (Devise + Pundit) |
| `test/integration/api_authorization_test.rb` | API ได้ 401 / 403 / 201 และ login คืน role |
| `test/integration/admin_access_test.rb` | `/admin` ทุกหน้าและทุกฟอร์ม, admin ลบหรือลดสิทธิ์ตัวเองไม่ได้ |
