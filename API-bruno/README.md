# Bruno — ชุดทดสอบหลัก

เปิด Rails ที่ `http://localhost:3000` และเปิด Cookie Jar ของ Bruno ชุดนี้ใช้ session cookie + CSRF ไม่ใช้ Bearer

กดตามลำดับโฟลเดอร์:

| ลำดับ | ส่วน | กรณีหลัก |
|---|---|---|
| 01 Login - Logout | CSRF → admin Login/Logout → customer Login/Logout → admin Login เพื่อเริ่ม CRUD |
| 02 Category | สร้าง ดูรายการ ดูรายตัว แก้ไข; error ชื่อว่าง ชื่อซ้ำ ไม่พบ ID และแก้ไขไม่ผ่าน |
| 03 Market | สร้าง ดูรายการ ดูรายตัว แก้ไข; error ชื่อว่าง ชื่อซ้ำ ไม่พบ ID และแก้ไขไม่ผ่าน |
| 04 User | สร้าง customer และ admin, ดูรายการ/รายตัว, แก้ไขทั้งสองบัญชี; error อีเมลซ้ำ ไม่พบ ID role ไม่ถูกต้อง และ admin ลด role/ลบบัญชีตัวเอง |
| 05 Book | สร้างพร้อม Market ดูรายการ ดูรายตัว แก้ไข ค้นหา กรองหมวด; error ข้อมูลไม่ครบ/ราคาติดลบ ไม่พบ ID แก้ไขไม่ผ่าน (และเช็คว่า Market ไม่หาย) ร้าน/หมวดที่ไม่มีอยู่ ราคาเกินเพดาน และลบหมวดที่ยังมีหนังสือ |
| 06 Delete | ลบ Book → Market → Category → Customer → Admin ที่สร้างทดสอบ แล้วลบ Book ซ้ำเพื่อเช็ค 404 |

มี 54 requests รวมการเตรียมข้อมูลกับการลบ ครอบคลุมทุก API ทั้งเคสสำเร็จและเคส error ยังไม่รวมตารางตรวจสิทธิ์ (401/403) ทุก method

- `base_url` กำหนดไว้ใน Collection Variables เป็น `http://localhost:3000`
- script เก็บ CSRF token และ ID จาก response ให้อัตโนมัติ เริ่มที่ request `01 Prepare CSRF` แล้วไล่ตามลำดับ
- `200` อ่าน/แก้ไข/Login สำเร็จ, `201` สร้างสำเร็จ, `204` ลบ/Logout สำเร็จ, `404` ไม่พบ ID, `422` validation error ที่ตั้งใจทดสอบ
- ดูผล script ในแท็บ Tests ของแต่ละ request
- บัญชี seed: `admin@example.com` / `1234` และ `user@example.com` / `1234` ถ้าเปลี่ยนรหัสแล้วให้แก้ Body ของ Login
- ตัวอย่างหนังสือใช้ชื่อ Clean Code / The Clean Coder ของ Robert C. Martin หมวดการเขียนโปรแกรม และร้านหนังสือบ้านนักอ่าน ไม่เติมเลขท้ายชื่อสินค้า
- Customer ตัวอย่าง: `narin.reader@example.com` / `1234`; แก้ไขเป็น `narin.customer@example.com`
- Admin ตัวอย่าง: `mali.admin@example.com` / `1234`; แก้ไขเป็น `mali.manager@example.com`
- ไม่มีตัวแปรในอีเมลหรือชื่อสินค้าแล้ว ส่วน `customer_id` และ `admin_id` เป็นเลขที่ API คืนตอนสร้าง script เก็บให้เพื่อเปิด/แก้/ลบให้ถูกบัญชี ไม่ใช่บัญชี admin ที่กำลัง Login
- ถ้ารัน Create อีเมลเดิมซ้ำก่อนลบ จะได้ 422 ตาม validation ต้องจัดการข้อมูลรอบก่อนหรือเปลี่ยนอีเมลก่อนสร้างใหม่
- การลบใช้เฉพาะ ID ที่สร้างในรอบนี้ ไม่ลบบัญชี Login จาก seed หรือหนังสือชื่อเดียวกันที่มีอยู่ก่อน
- ถ้าหยุดก่อนโฟลเดอร์ Delete จะมีข้อมูลทดสอบค้างไว้ ต้องกดลบต่อขณะที่ยังมี ID ใน runtime
- `06 Login Admin for CRUD` เก็บ ID ของ admin ที่ Login ไว้ใน `current_admin_id` เพื่อใช้ทดสอบว่า admin ลด role หรือลบบัญชีตัวเองไม่ได้
- ชื่อ Category/Market ห้ามซ้ำ ถ้ารอบก่อนรันไม่จบ `01 Create` จะได้ 422 ต้องลบข้อมูลที่ค้างก่อน
