
class Trade < ApplicationRecord
  TRADE_TYPES = ["buy","sell"]

  validates :trade_type, inclusion: { in: TRADE_TYPES }
  validates_numericality_of :shares, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :shares, :only_integer => true, :less_than_or_equal_to => 100

  def self.filter_by_user_id_and_trade_type user_id, trade_type
    trades = self.all
    trades = trades.where(user_id: user_id) if user_id
    trades = trades.where(trade_type: trade_type) if trade_type
    trades
  end
end
