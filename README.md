# Book Store

ร้านหนังสือออนไลน์ด้วย Ruby on Rails มีหน้าเว็บสำหรับลูกค้าและ admin พร้อม JSON API และชุดทดสอบ API ด้วย Bruno

## ฟีเจอร์

**ลูกค้า (customer)**
- สมัครสมาชิก / Login / Logout / ลืมรหัสผ่าน / แก้ไขบัญชี (Devise)
- ดูรายการหนังสือทั้งหมด
- กรองหนังสือตามหมวดด้วยปุ่มหมวดหมู่
- ค้นหาหนังสือจากชื่อ
- กดหนังสือเพื่อดูหน้ารายละเอียด

**ผู้ดูแล (admin)**
- หลังบ้าน ActiveAdmin (`/admin`) เข้าได้เฉพาะ admin มี Dashboard, ค้นหา/กรอง และ dark mode
- เพิ่ม แก้ไข ลบ หนังสือ (ทำจากหน้าบ้านได้ด้วย)
- เพิ่ม แก้ไข ลบ หมวดหมู่ (Category, one-to-many กับ Book)
- เพิ่ม แก้ไข ลบ ร้าน (Market, many-to-many กับ Book)
- สร้าง แก้ไข ลบ ผู้ใช้ และกำหนด role (admin ลบหรือลดสิทธิ์ตัวเองไม่ได้)

**API**
- JSON API ที่ `/api/v1` สำหรับ Book, Category, Market และ User ดูรายละเอียดใน [docs/API.md](docs/API.md)
- ชุดทดสอบ Bruno 54 requests ครอบคลุมทุก API ทั้งเคสสำเร็จและเคส error ดู [API-bruno/README.md](API-bruno/README.md)

## ระบบสิทธิ์ (4 gem)

อธิบายทีละ gem ว่าแก้ไฟล์ไหน เพราะอะไร และวิธีทดสอบ ใน **[docs/gems.md](docs/gems.md)**

| Gem | หน้าที่ในโปรเจกต์นี้ | ไฟล์หลัก |
|---|---|---|
| **Devise** | ล็อกอิน สมัครสมาชิก ลืมรหัสผ่าน (หน้าเว็บและ API ใช้ session เดียวกัน) | `app/models/user.rb`, `app/views/devise/` |
| **Rolify** | role ของ user: `customer` (ค่าเริ่มต้น) หรือ `admin` | `app/models/user.rb`, `app/models/role.rb` |
| **Pundit** | ตัดสินว่าใครทำอะไรได้ ทั้งหน้าบ้านและ API | `app/policies/` |
| **ActiveAdmin v4** | หลังบ้าน `/admin` ใช้ Devise ล็อกอิน และ Pundit policy แยก namespace | `app/admin/`, `app/policies/active_admin/` |

| การกระทำ | Guest | Customer | Admin |
|---|---|---|---|
| ดูหนังสือ / หมวด / ร้าน บนหน้าเว็บ | ✅ | ✅ | ✅ |
| อ่านข้อมูลผ่าน API | ❌ (401) | ✅ | ✅ |
| เพิ่ม แก้ ลบ หนังสือ / หมวด / ร้าน | ❌ | ❌ | ✅ |
| จัดการผู้ใช้ | ❌ | ❌ | ✅ |
| เข้า `/admin` | ❌ ไปหน้า Login | ❌ redirect พร้อม alert | ✅ |

## เทคโนโลยี

| ส่วน | เวอร์ชัน |
|---|---|
| Ruby | 4.0.9 |
| Rails | 8.1 |
| ฐานข้อมูล | PostgreSQL |
| Node.js | 26.13.0 |
| JavaScript bundler | esbuild (รันผ่าน Yarn) |
| CSS | Tailwind CSS 4 (รันผ่าน Bun) แยก build หน้าบ้านกับ ActiveAdmin |
| Auth / สิทธิ์ | Devise 5, Rolify 6, Pundit 2.5, ActiveAdmin 4.0.0.beta23 |

## ติดตั้งและเปิดใช้งาน (Docker)

ต้องมีแค่ [Docker Desktop](https://www.docker.com/products/docker-desktop/) ไม่ต้องติดตั้ง Ruby, Node, Bun หรือ PostgreSQL

```zsh
git clone https://github.com/Nut-Natthawut/book_store.git
cd book_store
git switch gem
cp .env.example .env
docker compose up
```

ก่อน `docker compose up` ให้เปิด `.env` แล้วใส่ `ADMIN_PASSWORD` และ `CUSTOMER_PASSWORD` (อย่างน้อย 8 ตัวอักษร) อีเมลและรหัสผ่านของบัญชีตัวอย่างไม่ได้เขียนไว้ในโค้ด และ `.env` ถูก ignore ไม่ถูก commit

ครั้งแรกจะ build image และติดตั้ง gem/package ประมาณ 2–5 นาที เมื่อเห็น `Listening on http://0.0.0.0:3000` แล้ว:

| URL | ใช้ทำอะไร |
|---|---|
| http://localhost:3000 | หน้าร้าน |
| http://localhost:3000/admin | หลังบ้าน (ActiveAdmin) |
| http://localhost:8025 | Mailpit ดูอีเมลลืมรหัสผ่าน |

container จะสร้างฐานข้อมูลและรัน seed ให้อัตโนมัติในครั้งแรก คำสั่งอื่น ๆ รันผ่าน `docker compose exec web ...` เช่น:

```zsh
docker compose exec web bin/rails test       # รัน test
docker compose exec web bin/rails db:seed    # รัน seed ซ้ำ
docker compose exec web bin/rails console
docker compose down                          # ปิด (ข้อมูลยังอยู่) เพิ่ม -v ถ้าต้องการล้างฐานข้อมูล
```

## ทางเลือก: รันบนเครื่องด้วย bin/dev (ไม่ใช้ Docker)

ต้องติดตั้ง Ruby, Node, Bun และ PostgreSQL เอง ทำขั้น `git clone`, `git switch gem` และสร้าง `.env` ตามหัวข้อด้านบนก่อน แล้วทำต่อดังนี้

### 1. ติดตั้งเครื่องมือที่ต้องใช้

ถ้ายังไม่มี [Homebrew](https://brew.sh) ให้ติดตั้งก่อน แล้วรัน:

```zsh
brew install mise postgresql@16 oven-sh/bun/bun
brew services start postgresql@16
```

- **mise** ใช้ติดตั้ง Ruby และ Node ตามเวอร์ชันที่โปรเจกต์กำหนดใน `mise.toml`
- **PostgreSQL** คือฐานข้อมูล คำสั่ง `brew services start` เปิดให้ทำงานอยู่เบื้องหลัง
- **Bun** ใช้ build ไฟล์ CSS

เพิ่ม 2 บรรทัดนี้ใน `~/.zshrc` แล้วเปิด terminal ใหม่:

```zsh
eval "$(mise activate zsh)"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
```

- บรรทัดแรกทำให้ใช้ Ruby และ Node ตามเวอร์ชันของโปรเจกต์อัตโนมัติ
- บรรทัดที่สองให้หาคำสั่งของ PostgreSQL เจอ (Homebrew ไม่ได้ใส่ PATH ให้) ถ้าไม่ใส่ `bundle install` จะติดตั้ง gem `pg` ไม่ผ่าน

### 2. ติดตั้ง Ruby, Node และ dependencies

```zsh
mise install            # ติดตั้ง Ruby 4.0.9 และ Node 26.13.0
npm install -g yarn     # ติดตั้ง Yarn
bundle install          # ติดตั้ง gem ของ Ruby
yarn install            # ติดตั้ง package ของ JavaScript
bun install             # ติดตั้ง package สำหรับ build CSS
```

### 3. สร้างฐานข้อมูลและข้อมูลตัวอย่าง

```zsh
bin/rails db:prepare    # สร้างฐานข้อมูลและตาราง (มีอยู่แล้วจะรัน migration ที่ค้าง)
bin/rails db:seed       # ใส่บัญชีผู้ใช้ (จาก .env) หมวดหมู่ ร้าน และหนังสือตัวอย่าง
```

ค่าเริ่มต้นจะต่อ PostgreSQL ในเครื่องด้วยชื่อผู้ใช้ macOS ของคุณ ถ้า PostgreSQL ของคุณต้องใช้ user หรือรหัสผ่านอื่น ให้ตั้ง `DATABASE_URL` ใน `.env`

### 4. เปิดเว็บ

```zsh
bin/dev
```

เปิด http://localhost:3000 ได้เลย `bin/dev` จะเปิด Rails server และคอย build JavaScript, CSS หน้าบ้าน และ CSS ของ ActiveAdmin ใหม่อัตโนมัติเมื่อแก้ไฟล์ กด `Ctrl + C` เพื่อปิด

อีเมลลืมรหัสผ่านถูกส่งไปที่ Mailpit (`localhost:1025`) ถ้าต้องการดูอีเมลให้เปิด Mailpit ด้วย `docker compose up mailpit` แล้วเข้า http://localhost:8025

## บัญชีสำหรับทดลอง

`bin/rails db:seed` สร้างบัญชีให้ 2 บัญชีตามค่าใน `.env`:

| ตัวแปรใน .env | Role |
|---|---|
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | admin |
| `CUSTOMER_EMAIL` / `CUSTOMER_PASSWORD` | customer |

seed รันได้เฉพาะ development รันซ้ำได้ ระบบจะไม่สร้างข้อมูลซ้ำ และไม่เปลี่ยนรหัสผ่านหรือ role ของบัญชีที่มีอยู่แล้ว สมัครบัญชี customer เพิ่มเองได้ที่หน้า "สมัครสมาชิก"

ข้อมูลตัวอย่างอื่นๆ ที่ seed สร้างให้:
- หมวดหมู่ 8 หมวด หมวดละ 5 เล่ม รวม 40 เล่ม
- ร้าน 3 ร้าน หนังสือแต่ละเล่มอยู่ใน 2 ร้าน

> ถ้าเคยรันโปรเจกต์ก่อน branch นี้ `bin/rails db:migrate` จะย้ายบัญชีเดิมไป Devise และย้าย role เดิมไป Rolify ให้ รหัสผ่านเดิมยังใช้ได้

## ลองใช้งาน

### หน้าเว็บ

1. เปิด http://localhost:3000 จะเห็นรายการหนังสือ ลองกดปุ่มหมวดหมู่ หรือพิมพ์ค้นหาชื่อหนังสือ
2. กดชื่อหนังสือเพื่อดูรายละเอียด (guest ไม่เห็นปุ่มแก้ไข/ลบ)
3. เปิด http://localhost:3000/admin ตอนยังไม่ Login จะถูกส่งไปหน้า Login
4. Login ด้วยบัญชี admin กด "หน้าจัดการ Admin" ลองเพิ่ม แก้ไข ลบ และกรองข้อมูล หนังสือ หมวดหมู่ ร้าน และผู้ใช้
5. ในหน้า Users ลองเปลี่ยน role ของ customer เป็น admin หรือสังเกตว่าบัญชีตัวเองไม่มีปุ่ม Delete
6. Logout (มุมขวาบนของ admin) แล้ว Login ด้วยบัญชี customer ลองเปิด `/admin` หรือ `/books/1/edit` จะถูก redirect พร้อมข้อความ "คุณไม่มีสิทธิ์ทำรายการนี้"
7. Logout แล้วกด "ลืมรหัสผ่าน?" ใส่อีเมล แล้วเปิด http://localhost:8025 จะเห็นอีเมลตั้งรหัสผ่านใหม่

### ทดสอบ API ด้วย Bruno

1. ติดตั้ง [Bruno](https://www.usebruno.com)
2. เปิด `docker compose up` หรือ `bin/dev` ค้างไว้ (Bruno ยิงไปที่ `http://localhost:3000`)
3. `cp .env API-bruno/collections/test-api/.env` ให้ request Login อ่านอีเมล/รหัสผ่านได้
4. ใน Bruno กด Open Collection แล้วเลือกโฟลเดอร์ `API-bruno`
5. คลิกขวาที่ collection **book-store** แล้วเลือก **Run** จะรันทั้ง 54 requests ตามลำดับ

รายละเอียดแต่ละโฟลเดอร์ใน [API-bruno/README.md](API-bruno/README.md)

## ตรวจคุณภาพโค้ด

```zsh
bin/rails test          # test ของ policy, model, หน้าเว็บ, API และ ActiveAdmin
bin/rubocop             # ตรวจสไตล์โค้ด (กฎ rubocop-rails-omakase)
bin/rubocop -a          # แก้จุดที่แก้อัตโนมัติได้
bin/brakeman            # ตรวจช่องโหว่ด้านความปลอดภัย
```

แนวทางเขียนโค้ดของโปรเจกต์อยู่ใน [CODING_STANDARDS.md](CODING_STANDARDS.md)

ถ้าใช้ VS Code แนะนำให้ติดตั้ง extension **Ruby LSP** (Shopify) ตัวเดียว มันใช้ RuboCop จาก Gemfile ของโปรเจกต์ให้อยู่แล้ว ไม่ต้องติดตั้ง extension RuboCop แยก

## แก้ปัญหาที่พบบ่อย

| อาการ | สาเหตุและวิธีแก้ |
|---|---|
| `docker compose up` ขึ้น `ไม่พบไฟล์ .env` | ยังไม่ได้ `cp .env.example .env` |
| `ยังไม่ได้ตั้งค่า ADMIN_PASSWORD ...` ตอน seed | ใส่ค่าใน `.env` ให้ครบ แล้วรัน `bin/rails db:seed` (Docker: `docker compose exec web bin/rails db:seed`) |
| เปิดเว็บได้แต่ไม่มีหนังสือ / ล็อกอินไม่ได้ | seed รอบแรกไม่สำเร็จ (เช่น รหัสใน `.env` สั้นกว่า 8 ตัว) container จะไม่รัน seed ซ้ำเองเพราะฐานข้อมูลมีแล้ว แก้ `.env` แล้วรัน `docker compose exec web bin/rails db:seed` |
| หน้า `/admin` ไม่มีสไตล์ | ยังไม่ได้ build CSS ของ admin รัน `bun run build:css:admin` หรือเช็คว่า process `css_admin` ใน `bin/dev` รันอยู่ |
| `connection to server ... failed` ตอน `db:prepare` | PostgreSQL ยังไม่ได้เปิด รัน `brew services start postgresql@16` |
| `role "..." does not exist` | PostgreSQL ไม่มี user ชื่อเดียวกับ macOS ให้รัน `createuser -s $(whoami)` หรือตั้ง `DATABASE_URL` |
| Bruno ขึ้น `request failed` ทุกข้อ | ยังไม่ได้เปิด `bin/dev` |
| Bruno ข้อ Login ได้ 429 | กด Run ติดกันหลายรอบเกินไป (Login จำกัด 10 ครั้งต่อ 3 นาที) รอสักครู่แล้วรันใหม่ |
| Bruno ข้อ Login ได้ 401 | ยังไม่ได้คัดลอก `.env` ไปที่ `API-bruno/collections/test-api/.env` |
| Bruno ข้อ `01 Create` ได้ 422 | รอบก่อนรันไม่จบ ข้อมูลทดสอบยังค้างอยู่ ชื่อหมวดหรือร้านจึงซ้ำ ให้ลบผ่านหน้า Admin แล้วรันใหม่ |
| Port 3000 ถูกใช้อยู่ | รัน `PORT=3001 bin/dev` แล้วแก้ `base_url` ใน Bruno ให้ตรงกัน |
