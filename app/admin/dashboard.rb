ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "grid gap-4 md:grid-cols-4 mb-8" do
      [
        [ "Books", Book.count ],
        [ "Categories", Category.count ],
        [ "Markets", Market.count ],
        [ "Users", User.count ]
      ].each do |label, value|
        div class: "rounded-lg border border-gray-200 dark:border-gray-800 p-4" do
          para label, class: "text-sm text-gray-500"
          para value.to_s, class: "text-3xl font-semibold"
        end
      end
    end

    panel "Recent books" do
      table_for Book.includes(:category).order(created_at: :desc).limit(5) do
        column(:title) { |book| link_to book.title, admin_book_path(book) }
        column :category
        column(:price) { |book| number_to_currency(book.price, unit: "฿") }
      end
    end
  end
end
