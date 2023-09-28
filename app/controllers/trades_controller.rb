class TradesController < ApplicationController
  before_action :prohibited, only: [:update, :delete]

  def index
    trades = Trade.filter_by_user_id_and_trade_type params[:user_id], params[:trade_type]
    render json: trades, status: 200
  end

  def show
    trade = Trade.find_by_id(params[:id])
    if trade
      render json: trade, status: 200
    else
      render json: {errors: ["Record Not found"]}, status: 404
    end
  end

  def create
    trade = Trade.new(trade_params)
    if trade.save
      render json: trade, status: 201
    else
      render json: {
        errors: trade.errors.messages,
      }, status: 400
    end
  end

  def update
  end

  def delete
  end


  private

  def prohibited
    return render json: {
      errors: ['Action Not allowed']
    }, status: 405
  end
  # Only allow trade list of trusted parameters through.
  def trade_params
    params.permit(:trade_type, :user_id, :symbol, :shares, :price, :timestamp)
  end
end
