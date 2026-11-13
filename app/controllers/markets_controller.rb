class MarketsController < ApplicationController
  before_action :require_admin
  before_action :find_market, only: [ :edit, :update, :destroy ]

  def index
    @markets = Market.order(:name)
  end

  def new
    @market = Market.new
  end

  def create
    @market = Market.new(market_params)

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
    @market = Market.find(params[:id])
  end

  def market_params
    params.expect(market: [ :name ])
  end
end
