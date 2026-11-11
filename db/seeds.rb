# ข้อมูลสมมติสำหรับ local development
users = [
  { email_address: "admin@example.com", role: "admin" },
  { email_address: "user@example.com", role: "customer" }
]

# ตรวจบัญชีเดิมก่อนสร้างข้อมูล ไม่เปลี่ยน role หรือรหัสผ่านเดิม
users.each do |attributes|
  user = User.find_by(email_address: attributes[:email_address])
  if user && user.role != attributes[:role]
    abort "บัญชี #{user.email_address} มี role ไม่ตรงกับ seed กรุณาตรวจสอบก่อน"
  end
end

users.each do |attributes|
  user = User.find_or_initialize_by(email_address: attributes[:email_address])

  if user.persisted?
    puts "มีบัญชี #{user.email_address} แล้ว ไม่เปลี่ยนข้อมูลเดิม"
  else
    user.assign_attributes(attributes)
    user.password = "1234"
    user.save!
    puts "สร้าง #{user.role}: #{user.email_address} / Password: 1234"
  end
end

# 8 หมวด หมวดละ 5 เล่ม รวม 40 เล่ม
categories = {
  "Programming" => ["เริ่มต้น Ruby", "สร้างเว็บด้วย Rails", "TypeScript ในงานจริง", "ออกแบบฐานข้อมูล", "พื้นฐาน JavaScript"],
  "Novel" => ["ร้านหนังสือริมทาง", "จดหมายจากวันวาน", "ฤดูฝนที่เราพบกัน", "บ้านหลังสุดท้าย", "ความลับในห้องสมุด"],
  "Science" => ["จักรวาลใกล้ตัว", "ฟิสิกส์ในชีวิตประจำวัน", "โลกของสิ่งมีชีวิต", "เคมีรอบบ้าน", "สำรวจระบบสุริยะ"],
  "History" => ["เรื่องเล่าจากอดีต", "เส้นทางอารยธรรม", "ประวัติศาสตร์การเดินทาง", "เมืองเก่าริมแม่น้ำ", "วันเปลี่ยนโลก"],
  "Business" => ["เริ่มธุรกิจเล็ก ๆ", "บัญชีสำหรับมือใหม่", "เข้าใจลูกค้า", "วางแผนการเงินธุรกิจ", "บริหารทีมอย่างเข้าใจ"],
  "Self Development" => ["จัดเวลาให้ตัวเอง", "เริ่มต้นนิสัยใหม่", "ฝึกคิดอย่างเป็นระบบ", "สื่อสารให้เข้าใจ", "เป้าหมายเล็ก ๆ ทุกวัน"],
  "Cooking" => ["อาหารจานแรก", "ขนมอบในครัวบ้าน", "เมนูผักประจำวัน", "กาแฟแก้วโปรด", "ครัวไทยฉบับง่าย"],
  "Travel" => ["เที่ยวเมืองเหนือ", "บันทึกริมทะเล", "เดินทางด้วยรถไฟ", "พักใจในเมืองเล็ก", "เตรียมตัวเที่ยวต่างประเทศ"]
}

categories.each do |name, titles|
  category = Category.find_or_create_by!(name: name)

  titles.each_with_index do |title, index|
    Book.find_or_create_by!(title: title, author: "Book Store") do |book|
      book.description = "หนังสือสมมติสำหรับทดลองระบบ หมวด #{name}: #{title}"
      book.price = 199 + (index * 50)
      book.category = category
    end
  end
end

puts "เตรียมข้อมูลตัวอย่าง 8 หมวดและ 40 เล่มแล้ว โดยไม่สร้างรายการเดิมซ้ำ"
