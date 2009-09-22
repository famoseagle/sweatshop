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

  should "daemonize" do
    begin
      SweatShop.config['enable'] = true
      SweatShop.logger = :silent

      HelloWorker.async_hello('Amos')

      worker = File.expand_path(File.dirname(__FILE__) + '/hello_worker')
      sweatd = "#{File.dirname(__FILE__)}/../lib/sweat_shop/sweatd.rb" 

      `ruby #{sweatd} --worker-file #{worker} start`
      `ruby #{sweatd} stop`

      File.delete('sweatd.log') if File.exist?('sweatd.log')
      assert_equal 'Hi, Amos', File.read(HelloWorker::TEST_FILE)
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
      fail "\n\n*** Functional test failed, is the rabbit server running on localhost? ***\n"
    end
  end
  
end
