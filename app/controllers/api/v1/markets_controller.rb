class Api::V1::MarketsController < Api::V1::BaseController
  before_action :require_admin, except: [ :index, :show ]
  before_action :find_market, only: [ :show, :update, :destroy ]

  def index
    render json: Market.order(id: :asc).map { |market| market_json(market) }
  end

  def show
    render json: market_json(@market)
  end

  def create
    @market = Market.new(market_params)

    if @market.save
      render json: market_json(@market), status: :created
    else
      render json: { errors: @market.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @market.update(market_params)
      render json: market_json(@market)
    else
      render json: { errors: @market.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @market.destroy
      head :no_content
    else
      render json: { errors: @market.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_market
    @market = Market.find(params[:id])
  end

  def market_json(market)
    market.as_json(only: [ :id, :name ])
  end

  def market_params
    params.expect(market: [ :name ])
  end
end
