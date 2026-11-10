class BooksController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
  before_action :require_admin, except: [:index, :show]
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:new, :create, :edit, :update]

  def index
    @categories = Category.order(:name)
    @category_id = params[:category_id].presence
    @query = params[:q].to_s.strip

    @books = Book.order(:title)
    @books = @books.where(category_id: @category_id) if @category_id.present?

    if @query.present?
      @books = @books.where("title ILIKE ?", "%#{Book.sanitize_sql_like(@query)}%")
    end
  end

  def show
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: "เพิ่มหนังสือแล้ว"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "แก้ไขหนังสือแล้ว", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy!
    redirect_to books_path, notice: "ลบหนังสือแล้ว", status: :see_other
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def set_categories
    @categories = Category.order(:name)
  end

  def book_params
    params.require(:book).permit(:title, :author, :description, :price, :category_id)
  end
end
