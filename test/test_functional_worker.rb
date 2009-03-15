require File.dirname(__FILE__) + '/../lib/sweat_shop'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/hello_worker'

class WorkerTest < Test::Unit::TestCase

  def setup
    File.delete(HelloWorker::TEST_FILE) if File.exist?(HelloWorker::TEST_FILE)
  end

  def teardown
    File.delete(HelloWorker::TEST_FILE) if File.exist?(HelloWorker::TEST_FILE)
  end

  # remove 'x' and start kestrel to run
  test "daemon" do
    begin
      SweatShop.queue = nil
      SweatShop::Worker.logger = :silent

      worker = File.expand_path(File.dirname(__FILE__) + '/hello_worker')
      sweatd = "#{File.dirname(__FILE__)}/../lib/sweat_shop/sweatd.rb" 
      uid = HelloWorker.async_hello('Amos')

      `ruby #{sweatd} --worker-file #{worker} start`
      `ruby #{sweatd} stop`

      File.delete('sweatd.log') if File.exist?('sweatd.log')
      assert_equal 'Hi, Amos', File.read(HelloWorker::TEST_FILE)
    rescue MemCache::MemCacheError => e
      puts "\n\n*** Start kestrel on localhost to run all functional tests. ***\n\n"
    end
  end
  
end
