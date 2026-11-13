class Book < ApplicationRecord
  belongs_to :category
  has_many :book_markets, dependent: :destroy
  has_many :markets, through: :book_markets

  validates :title, :author, :description, presence: true
  validates :price, numericality: { greater_than: 0, less_than: 100_000_000 }
  validate :market_ids_must_exist

  after_save :save_pending_markets

  # Rails' default market_ids= writes to book_markets immediately on a saved
  # record (even if validation later fails) and raises RecordNotFound for
  # unknown ids. Hold the ids until the book passes validation instead.
  def market_ids=(ids)
    @pending_market_ids = Array(ids).compact_blank.map(&:to_s).uniq
  end

  def market_ids
    @pending_market_ids&.map(&:to_i) || super
  end

  private

  def market_ids_must_exist
    return if @pending_market_ids.nil?

    found = Market.where(id: @pending_market_ids).count
    errors.add(:market_ids, "มีร้านที่ไม่มีอยู่จริง") if found != @pending_market_ids.size
  end

  def save_pending_markets
    return if @pending_market_ids.nil?

    self.markets = Market.where(id: @pending_market_ids)
    @pending_market_ids = nil
  end
end
