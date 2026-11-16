# ข้อมูลสมมติสำหรับ local development เท่านั้น
abort "db:seed ใช้ได้เฉพาะ development" unless Rails.env.development?

# อีเมลและรหัสผ่านอ่านจาก ENV (ไฟล์ .env) ห้าม hardcode ไว้ในโค้ด ดูตัวอย่างใน .env.example
missing = %w[ADMIN_EMAIL ADMIN_PASSWORD CUSTOMER_EMAIL CUSTOMER_PASSWORD].select { |key| ENV[key].blank? }
if missing.any?
  abort "ยังไม่ได้ตั้งค่า #{missing.join(", ")} ให้คัดลอก .env.example เป็น .env แล้วใส่รหัสผ่าน (อย่างน้อย 8 ตัวอักษร)"
end

users = [
  { email: ENV.fetch("ADMIN_EMAIL"), password: ENV.fetch("ADMIN_PASSWORD"), role: "admin" },
  { email: ENV.fetch("CUSTOMER_EMAIL"), password: ENV.fetch("CUSTOMER_PASSWORD"), role: "customer" }
]

# ตรวจบัญชีเดิมก่อนสร้างข้อมูล ไม่เปลี่ยน role หรือรหัสผ่านเดิม
users.each do |attributes|
  user = User.find_by(email: attributes[:email])
  if user && user.role != attributes[:role]
    abort "บัญชี #{user.email} มี role ไม่ตรงกับ seed กรุณาตรวจสอบก่อน"
  end
end

users.each do |attributes|
  user = User.find_or_initialize_by(email: attributes[:email])

  if user.persisted?
    puts "มีบัญชี #{user.email} แล้ว ไม่เปลี่ยนข้อมูลเดิม"
  else
    user.update!(attributes)
    puts "สร้าง #{user.role}: #{user.email}"
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

# ร้านสมมติ: หนังสือแต่ละเล่มอยู่ในร้านกลางเมืองและร้านเฉพาะทางอีกหนึ่งแห่ง
markets = {
  "ร้านหนังสือกลางเมือง" => categories.keys,
  "ร้านหนังสือเรียนรู้" => ["Programming", "Science", "Business", "Self Development"],
  "ร้านหนังสือวันพักผ่อน" => ["Novel", "History", "Cooking", "Travel"]
}

markets.each do |name, category_names|
  market = Market.find_or_create_by!(name: name)
  titles = categories.values_at(*category_names).flatten

  Book.where(title: titles, author: "Book Store").find_each do |book|
    BookMarket.find_or_create_by!(book: book, market: market)
  end
end

puts "เตรียมร้านตัวอย่าง 3 ร้าน และผูกหนังสือผ่าน book_markets แล้ว"
