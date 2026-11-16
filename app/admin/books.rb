ActiveAdmin.register Book do
  permit_params :title, :author, :description, :price, :category_id, market_ids: []

  includes :category # กัน N+1 query ในหน้า index

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :category
    column(:price) { |book| number_to_currency(book.price, unit: "฿") }
    actions
  end

  filter :title
  filter :author
  filter :category, collection: -> { Category.order(:name) }
  filter :markets, collection: -> { Market.order(:name) }
  filter :price

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :title
      f.input :author
      f.input :description
      f.input :price, min: 0.01, max: 99_999_999.99, step: 0.01
      f.input :category, collection: Category.order(:name)
      f.input :markets, as: :check_boxes, collection: Market.order(:name)
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :author
      row :category
      row(:price) { |book| number_to_currency(book.price, unit: "฿") }
      row(:description) { |book| simple_format(book.description) }
      row(:markets) { |book| book.markets.map(&:name).join(", ") }
      row :created_at
      row :updated_at
    end
  end
end
