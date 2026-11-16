class BooksController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :find_book, only: [ :show, :edit, :update, :destroy ]
  # กันลืม: action ไหนไม่เรียก authorize / policy_scope จะ raise error ทันที
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  before_action :load_categories, only: [ :new, :create, :edit, :update ]
  before_action :load_markets, only: [ :new, :create, :edit, :update ]

  def index
    @categories = Category.order(:name)
    @category_id = params[:category_id].presence
    @query = params[:q].to_s.strip

    @books = policy_scope(Book).order(:title)
    @books = @books.where(category_id: @category_id) if @category_id.present?

    if @query.present?
      @books = @books.where("title ILIKE ?", "%#{Book.sanitize_sql_like(@query)}%")
    end
  end

  def show
  end

  def new
    @book = authorize Book.new
  end

  def create
    @book = authorize Book.new(book_params)

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

  def find_book
    @book = authorize Book.find(params[:id])
  end

  def load_categories
    @categories = Category.order(:name)
  end

  def load_markets
    @markets = Market.order(:name)
  end

  def book_params
    params.expect(book: [ :title, :author, :description, :price, :category_id, market_ids: [] ])
  end
end
