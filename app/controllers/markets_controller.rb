class MarketsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_market, only: [ :edit, :update, :destroy ]
  after_action :verify_authorized

  def index
    authorize Market, :update?
    @markets = Market.order(:name)
  end

  def new
    @market = authorize Market.new
  end

  def create
    @market = authorize Market.new(market_params)

    if @market.save
      redirect_to markets_path, notice: "เพิ่มร้านแล้ว"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @market.update(market_params)
      redirect_to markets_path, notice: "แก้ไขร้านแล้ว", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @market.destroy!
    redirect_to markets_path, notice: "ลบร้านแล้ว", status: :see_other
  end

  private

  def find_market
    @market = authorize Market.find(params[:id])
  end

  def market_params
    params.expect(market: [ :name ])
  end
end
