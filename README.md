# Book Store

ร้านหนังสือออนไลน์ด้วย Ruby on Rails มีหน้าเว็บสำหรับลูกค้าและ admin พร้อม JSON API และชุดทดสอบ API ด้วย Bruno

## ฟีเจอร์

**ลูกค้า (customer)**
- Login / Logout
- ดูรายการหนังสือทั้งหมด
- กรองหนังสือตามหมวดด้วยปุ่มหมวดหมู่
- ค้นหาหนังสือจากชื่อ
- กดหนังสือเพื่อดูหน้ารายละเอียด

**ผู้ดูแล (admin)**
- หน้า Admin (`/admin`) เข้าได้เฉพาะ admin
- เพิ่ม แก้ไข ลบ หนังสือ
- เพิ่ม แก้ไข ลบ หมวดหมู่ (Category, one-to-many กับ Book)
- เพิ่ม แก้ไข ลบ ร้าน (Market, many-to-many กับ Book)
- สร้างผู้ใช้ใหม่

**API**
- JSON API ที่ `/api/v1` สำหรับ Book, Category, Market และ User ดูรายละเอียดใน [docs/API.md](docs/API.md)
- ชุดทดสอบ Bruno 54 requests ครอบคลุมทุก API ทั้งเคสสำเร็จและเคส error ดู [API-bruno/README.md](API-bruno/README.md)

## เทคโนโลยี

| ส่วน | เวอร์ชัน |
|---|---|
| Ruby | 4.0.9 |
| Rails | 8.1 |
| ฐานข้อมูล | PostgreSQL |
| Node.js | 26.13.0 |
| JavaScript bundler | esbuild (รันผ่าน Yarn) |
| CSS | Tailwind CSS 4 (รันผ่าน Bun) |

## ติดตั้ง (macOS)

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

### 2. Clone โปรเจกต์

```zsh
git clone https://github.com/Nut-Natthawut/book_store.git
cd book_store
```

### 3. ติดตั้ง Ruby, Node และ dependencies

```zsh
mise install            # ติดตั้ง Ruby 4.0.9 และ Node 26.13.0
npm install -g yarn     # ติดตั้ง Yarn
bundle install          # ติดตั้ง gem ของ Ruby
yarn install            # ติดตั้ง package ของ JavaScript
bun install             # ติดตั้ง package สำหรับ build CSS
```

### 4. สร้างฐานข้อมูลและข้อมูลตัวอย่าง

```zsh
bin/rails db:prepare    # สร้างฐานข้อมูลและตาราง
bin/rails db:seed       # ใส่บัญชีผู้ใช้ หมวดหมู่ ร้าน และหนังสือตัวอย่าง
```

ค่าเริ่มต้นจะต่อ PostgreSQL ในเครื่องด้วยชื่อผู้ใช้ macOS ของคุณ ถ้า PostgreSQL ของคุณต้องใช้ user หรือรหัสผ่านอื่น ให้ตั้ง environment variable ก่อนรันคำสั่ง เช่น:

```zsh
export DATABASE_URL="postgres://<user>:<password>@localhost:5432"
```

### 5. เปิดเว็บ

```zsh
bin/dev
```

เปิด http://localhost:3000 ได้เลย `bin/dev` จะเปิด Rails server และคอย build JavaScript กับ CSS ใหม่อัตโนมัติเมื่อแก้ไฟล์ กด `Ctrl + C` เพื่อปิด

## บัญชีสำหรับทดลอง

`bin/rails db:seed` สร้างบัญชีให้ 2 บัญชี:

| อีเมล | Role |
|---|---|
| admin@example.com | admin |
| user@example.com | customer |

รหัสผ่านกำหนดไว้ใน `db/seeds.rb` ใช้สำหรับเครื่อง development เท่านั้น ห้ามรัน seed นี้บน production

รัน seed ซ้ำได้ ระบบจะไม่สร้างข้อมูลซ้ำ และไม่เปลี่ยนรหัสผ่านหรือ role ของบัญชีที่มีอยู่แล้ว

ข้อมูลตัวอย่างอื่นๆ ที่ seed สร้างให้:
- หมวดหมู่ 8 หมวด หมวดละ 5 เล่ม รวม 40 เล่ม
- ร้าน 3 ร้าน หนังสือแต่ละเล่มอยู่ใน 2 ร้าน

## ลองใช้งาน

### หน้าเว็บ

1. เปิด http://localhost:3000 จะเห็นรายการหนังสือ ลองกดปุ่มหมวดหมู่ หรือพิมพ์ค้นหาชื่อหนังสือ
2. กดชื่อหนังสือเพื่อดูรายละเอียด
3. Login ด้วยบัญชี admin แล้วไปที่ http://localhost:3000/admin
4. ลองเพิ่ม แก้ไข และลบ หนังสือ หมวดหมู่ ร้าน หรือสร้างผู้ใช้ใหม่
5. Logout แล้ว Login ด้วยบัญชี customer ลองเปิด `/admin` จะเข้าไม่ได้

### ทดสอบ API ด้วย Bruno

1. ติดตั้ง [Bruno](https://www.usebruno.com)
2. เปิด `bin/dev` ค้างไว้ (Bruno ยิงไปที่ `http://localhost:3000`)
3. ใน Bruno กด Open Collection แล้วเลือกโฟลเดอร์ `API-bruno`
4. คลิกขวาที่ collection **book-store** แล้วเลือก **Run** จะรันทั้ง 54 requests ตามลำดับ

รายละเอียดแต่ละโฟลเดอร์ใน [API-bruno/README.md](API-bruno/README.md)

## ตรวจคุณภาพโค้ด

```zsh
bin/rubocop             # ตรวจสไตล์โค้ด (กฎ rubocop-rails-omakase)
bin/rubocop -a          # แก้จุดที่แก้อัตโนมัติได้
bin/brakeman            # ตรวจช่องโหว่ด้านความปลอดภัย
```

แนวทางเขียนโค้ดของโปรเจกต์อยู่ใน [CODING_STANDARDS.md](CODING_STANDARDS.md)

ถ้าใช้ VS Code แนะนำให้ติดตั้ง extension **Ruby LSP** (Shopify) ตัวเดียว มันใช้ RuboCop จาก Gemfile ของโปรเจกต์ให้อยู่แล้ว ไม่ต้องติดตั้ง extension RuboCop แยก

## แก้ปัญหาที่พบบ่อย

| อาการ | สาเหตุและวิธีแก้ |
|---|---|
| `connection to server ... failed` ตอน `db:prepare` | PostgreSQL ยังไม่ได้เปิด รัน `brew services start postgresql@16` |
| `role "..." does not exist` | PostgreSQL ไม่มี user ชื่อเดียวกับ macOS ให้รัน `createuser -s $(whoami)` หรือตั้ง `DATABASE_URL` |
| Bruno ขึ้น `request failed` ทุกข้อ | ยังไม่ได้เปิด `bin/dev` |
| Bruno ข้อ Login ได้ 429 | กด Run ติดกันหลายรอบเกินไป (Login จำกัด 10 ครั้งต่อ 3 นาที) รอสักครู่แล้วรันใหม่ |
| Bruno ข้อ `01 Create` ได้ 422 | รอบก่อนรันไม่จบ ข้อมูลทดสอบยังค้างอยู่ ชื่อหมวดหรือร้านจึงซ้ำ ให้ลบผ่านหน้า Admin แล้วรันใหม่ |
| Port 3000 ถูกใช้อยู่ | รัน `PORT=3001 bin/dev` แล้วแก้ `base_url` ใน Bruno ให้ตรงกัน |
