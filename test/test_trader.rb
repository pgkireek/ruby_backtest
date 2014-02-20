require 'benchmark'
require_relative "test_master"
require_relative "../lib/trader/trader"
require_relative "../lib/backtest_order_manager/backtest_order_manager"

class TestTrader < TestMaster
  def setup
    @feeds = PriceFeeds.new
    @manager = BacktestOrderManager.new
    @trader = TraderMock.new(@feeds, @manager)
  end
  
  def test_setup
    base_date = Time.parse("2007.01.02 07:00")
    assert_nothing_raised("Setup load error."){
      @trader.setup
      @trader.set_base_symbol(:USDJPY60, base_date)
    }
  end
  
  def test_run
    base_date = Time.parse("2007.01.10 07:00")
    @trader.setup
    @trader.set_base_symbol(:USDJPY60, base_date)
    @trader.set_spread(:USDJPY60, 0.003)
    100.times{
      @trader.run
      @feeds.go_forward
    }
    #pos = @manager.get_all_positions
    #assert_equal(pos[0].order_type, 1, "OrderType is wrong.")
    #assert_equal(pos[0].open_price, 119.363, "OpenPrice is wrong.")
    #assert_equal(pos[0].close_price, 119.36, "ClosePrice is wrong.")
    #assert_equal(pos[1].order_type, 2, "OrderType is wrong.")
    #assert_equal(pos[1].open_price, 119.34, "OpenPrice is wrong.")
    #assert_equal(pos[1].close_price, 119.353, "ClosePrice is wrong.")
  end
  
  def test_benchmark
    base_date = Time.parse("2007.01.10 07:00")
    @trader.setup
    @trader.set_base_symbol(:USDJPY60, base_date)
    @trader.set_spread(:USDJPY60, 0.003)
    puts Benchmark::CAPTION
    puts Benchmark.measure {
      month = 0
      symbol = :USDJPY60
      2500000.times{
        #now_month = @feeds.time(symbol, 0).month
        #print(@feeds.time(symbol, 0).to_s + "\r") unless month == now_month
        #month = now_month
        @trader.run
        @feeds.go_forward
      }
    }
    puts @feeds.time(:USDJPY60, 0)
  end
end