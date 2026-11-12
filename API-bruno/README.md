# Bruno — ชุดทดสอบหลัก

เปิด Rails ที่ `http://localhost:3000` และเปิด Cookie Jar ของ Bruno ชุดนี้ใช้ session cookie + CSRF ไม่ใช้ Bearer

กดตามลำดับโฟลเดอร์:

| ลำดับ | ส่วน | กรณีหลัก |
|---|---|---|
| 01 Login - Logout | CSRF → admin Login/Logout → customer Login/Logout → admin Login เพื่อเริ่ม CRUD |
| 02 Category | สร้าง ดูรายการ ดูรายตัว แก้ไข และ error ชื่อว่าง |
| 03 Market | สร้าง ดูรายการ ดูรายตัว แก้ไข และ error ชื่อว่าง |
| 04 User | สร้าง customer และ admin, error อีเมลซ้ำ, ดูรายการ/รายตัว และแก้ไขทั้งสองบัญชี |
| 05 Book | สร้างพร้อม Market ดูรายการ ดูรายตัว แก้ไข ค้นหา กรองหมวด และ error ข้อมูลไม่ครบ/ราคาติดลบ |
| 06 Delete | ลบ Book → Market → Category → Customer → Admin ที่สร้างทดสอบ |

มี 36 requests รวมการเตรียมข้อมูลกับการลบ ใช้เท่าที่ต้องแสดงผลสำเร็จและ error ไม่รวม edge cases หรือตารางตรวจสิทธิ์ทุก method

- `base_url` กำหนดไว้ใน Collection Variables เป็น `http://localhost:3000`
- script เก็บ CSRF token และ ID จาก response ให้อัตโนมัติ เริ่มที่ request `01 Prepare CSRF` แล้วไล่ตามลำดับ
- `200` อ่าน/แก้ไข/Login สำเร็จ, `201` สร้างสำเร็จ, `204` ลบ/Logout สำเร็จ, `422` validation error ที่ตั้งใจทดสอบ
- ดูผล script ในแท็บ Tests ของแต่ละ request
- บัญชี seed: `admin@example.com` / `1234` และ `user@example.com` / `1234` ถ้าเปลี่ยนรหัสแล้วให้แก้ Body ของ Login
- ตัวอย่างหนังสือใช้ชื่อ Clean Code / The Clean Coder ของ Robert C. Martin หมวดการเขียนโปรแกรม และร้านหนังสือบ้านนักอ่าน ไม่เติมเลขท้ายชื่อสินค้า
- Customer ตัวอย่าง: `narin.reader@example.com` / `1234`; แก้ไขเป็น `narin.customer@example.com`
- Admin ตัวอย่าง: `mali.admin@example.com` / `1234`; แก้ไขเป็น `mali.manager@example.com`
- ไม่มีตัวแปรในอีเมลหรือชื่อสินค้าแล้ว ส่วน `customer_id` และ `admin_id` เป็นเลขที่ API คืนตอนสร้าง script เก็บให้เพื่อเปิด/แก้/ลบให้ถูกบัญชี ไม่ใช่บัญชี admin ที่กำลัง Login
- ถ้ารัน Create อีเมลเดิมซ้ำก่อนลบ จะได้ 422 ตาม validation ต้องจัดการข้อมูลรอบก่อนหรือเปลี่ยนอีเมลก่อนสร้างใหม่
- การลบใช้เฉพาะ ID ที่สร้างในรอบนี้ ไม่ลบบัญชี Login จาก seed หรือหนังสือชื่อเดียวกันที่มีอยู่ก่อน
- ถ้าหยุดก่อนโฟลเดอร์ Delete จะมีข้อมูลทดสอบค้างไว้ ต้องกดลบต่อขณะที่ยังมี ID ใน runtime
- ยังไม่ได้รันชุดที่ย่อนี้ผ่าน Bruno ผู้ใช้เป็นคนกดตรวจเอง
