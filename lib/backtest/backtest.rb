require_relative "../trader/trader"
require_relative "../backtest_order_manager/backtest_order_manager"
require_relative "../price_feeds/clibrary/price_feeds"
class Backtest
  def initialize(trader)
    @feeds = PriceFeeds.new
    @manager = BacktestOrderManager.new
    @trader = trader.new(@feeds, @manager)
  end
  
  # Start Backtesting
  def run(symbol, start_date, end_date, spread_list = {})
    @trader.setup
    @trader.set_base_symbol(symbol, start_date)
    spread_list.each{|sym, spread|
      @trader.set_spread(sym, spread)
    }
    month = 0
    while(true)
      #print(@feeds.time(symbol, 0).to_s + "\r") unless month == @feeds.time(symbol, 0).month
      #month = @feeds.time(symbol, 0).month
      @trader.run
      begin
        @feeds.go_forward
      rescue PriceFeeds::OutOfRangeException
        break
      end
    end
    close_all_positions
    @trader.finalize
  end
  
  private
  def close_all_positions
    @trader.get_open_positions.each{|pos|
      @trader.close_order(pos)
    }
  end
end