ActiveAdmin.register Market do
  permit_params :name

  config.sort_order = "name_asc"

  index do
    selectable_column
    id_column
    column :name
    column("Books", sortable: false) { |market| market.books.size }
    actions
  end

  filter :name

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :created_at
    end

    panel "Books" do
      table_for market.books.order(:title) do
        column(:title) { |book| link_to book.title, admin_book_path(book) }
      end
    end
  end
end
