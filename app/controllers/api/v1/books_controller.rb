class Api::V1::BooksController < Api::V1::BaseController
  before_action :require_admin, except: [ :index, :show ]
  before_action :find_book, only: [ :show, :update, :destroy ]

  def index
    books = Book.includes(:category, :markets).order(id: :asc)
    books = books.where(category_id: params[:category_id]) if params[:category_id].present?
    query = params[:q].to_s.strip
    books = books.where("title ILIKE ?", "%#{Book.sanitize_sql_like(query)}%") if query.present?

    render json: books.map { |book| book_json(book) }
  end

  def show
    render json: book_json(@book)
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      render json: book_json(@book), status: :created
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: book_json(@book)
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy!
    head :no_content
  end

  private

  def find_book
    @book = Book.find(params[:id])
  end

  def book_json(book)
    data = book.as_json(
      only: [ :id, :title, :author, :description, :price, :category_id ],
      include: {
        category: { only: [ :id, :name ] },
        markets: { only: [ :id, :name ] }
      }
    )
    data["markets"].sort_by! { |market| market["id"] }
    data
  end

  def book_params
    params.expect(book: [ :title, :author, :description, :price, :category_id, market_ids: [] ])
  end
end
