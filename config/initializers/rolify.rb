Rolify.configure do |config|
  # Role ของร้านมีชุดตายตัว (customer / admin) เก็บแถวใน roles ไว้แม้ไม่มีใครถือ role นั้นแล้ว
  config.remove_role_if_empty = false
end
