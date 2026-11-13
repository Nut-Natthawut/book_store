# Book Store JSON API

Base URL: `http://localhost:3000/api/v1`

API ใช้ Model และ session cookie เดิมของ Rails ไม่ใช้ Bearer token ต้อง Login ก่อนอ่านข้อมูลทุก Model; customer อ่าน Book/Category/Market ได้ แต่เขียนไม่ได้; User ทุก action และการเขียนข้อมูลทุก Model ให้เฉพาะ admin

## Authentication สำหรับ Bruno หรือ HTTP client

เปิด cookie jar ให้เก็บและส่ง cookies ของ host เดิมทุก request

1. `GET /api/v1/session/new` คืน `{ "csrf_token": "..." }` และ session cookie
2. ส่ง `POST /api/v1/session` พร้อม header `X-CSRF-Token` จากข้อ 1 และ JSON `{ "email_address": "admin@example.com", "password": "1234" }`
3. Login สำเร็จคืน `{ "user": { "id": 1, "email_address": "...", "role": "admin" }, "csrf_token": "..." }` ใช้ token นี้กับ request เขียนข้อมูลต่อไป โดยส่ง cookie jar เดิม
4. Logout ด้วย `DELETE /api/v1/session` พร้อม `X-CSRF-Token` สำเร็จได้ 204 และ session ถูกยกเลิก

Request JSON ใช้ `Content-Type: application/json` และ `Accept: application/json` ทุก POST/PATCH/PUT/DELETE ต้องมี CSRF token ที่ตรงกับ session cookie ไม่มีการปิด CSRF เพื่อให้เรียก API ง่ายขึ้น

บัญชีจาก seed: admin@example.com / 1234 และ user@example.com / 1234 (customer) ถ้าเปลี่ยนรหัสแล้วต้องใช้รหัสปัจจุบัน

## Endpoints

ใช้ชุดเดียวกันสำหรับ resource `books`, `categories`, `markets`, `users`:

| Method | Path | ผลสำเร็จ |
|---|---|---|
| GET | /api/v1/:resource | 200 JSON array |
| GET | /api/v1/:resource/:id | 200 JSON object |
| POST | /api/v1/:resource | 201 JSON object ที่สร้าง |
| PATCH / PUT | /api/v1/:resource/:id | 200 JSON object ที่แก้ไข |
| DELETE | /api/v1/:resource/:id | 204 ไม่มี body |

Book index รับ `q` และ `category_id` เช่น `/api/v1/books?q=Ruby&category_id=1` กรองและค้นพร้อมกันได้

รายการ index ทุก Model เรียงตาม `id ASC` (น้อยไปมาก) รวมผลค้นหา/กรอง Book ส่วน `markets` ที่แนบใน Book เรียงตาม ID เช่นกัน; show ค้นรายการเดียวจาก ID

## Request bodies

Book:

```json
{
  "book": {
    "title": "ตัวอย่าง API",
    "author": "Book Store",
    "description": "ตัวอย่างหนังสือ",
    "price": 299,
    "category_id": 1,
    "market_ids": [1, 2]
  }
}
```

Book response มี id/title/author/description/price/category_id พร้อม category `{id, name}` และ markets `[{id, name}]` การ update ที่ไม่ส่ง market_ids จะคงความสัมพันธ์เดิม; ส่ง `"market_ids": []` เพื่อล้างทุกร้าน

Category: `{ "category": { "name": "Programming" } }`

Market: `{ "market": { "name": "ร้านใหม่" } }`

Category/Market response มีเฉพาะ id และ name ชื่อห้ามซ้ำกัน โดยไม่สนตัวพิมพ์เล็กใหญ่ ("Novel" กับ "novel" ถือว่าซ้ำ) ซ้ำจะได้ 422

ราคา Book ต้องมากกว่า 0 และน้อยกว่า 100,000,000

ถ้า update Book ไม่ผ่าน validation ความสัมพันธ์กับ Market จะไม่เปลี่ยน

User (admin-only):

```json
{
  "user": {
    "email_address": "new@example.com",
    "password": "1234",
    "password_confirmation": "1234",
    "role": "customer"
  }
}
```

User response มีเฉพาะ id/email_address/role ไม่ส่ง password/password_digest หรือข้อมูล session การ update ที่ไม่ส่ง password จะคงรหัสเดิม; ถ้าเปลี่ยนรหัสให้ส่ง password และ password_confirmation

## Errors

JSON รูปแบบ `{ "errors": ["ข้อความ"] }`

- 400: ขาด object parameters เช่น book/category/market/user หรือส่งชนิดข้อมูลผิด เช่น `{"book":"invalid"}` หรือ `{"user":[]}`
- 401: ยังไม่ Login หรือ Login ไม่ถูกต้อง
- 403: Login แล้วแต่ไม่มีสิทธิ์
- 404: ID ของ resource ไม่มีอยู่
- 422: validation ไม่ผ่าน (รวมถึง category_id หรือ market_ids อ้างอิงข้อมูลที่ไม่มีอยู่) หรือ CSRF token ไม่ถูกต้อง
- 429: ลอง Login เกินกำหนด

ลบ Category ที่มี Book ไม่ได้ (422); ลบ Market ลบเฉพาะแถวเชื่อมและเก็บ Book ไว้; ลบ User จะลบ sessions ของบัญชีนั้นด้วย; admin ลบบัญชีตัวเองหรือเปลี่ยน role ตัวเองเป็น customer ไม่ได้ (422) เพื่อให้ระบบมี admin เหลืออยู่เสมอ
