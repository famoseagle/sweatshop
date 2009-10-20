require File.dirname(__FILE__) + '/../lib/sweatshop'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/hello_worker'

class WorkerTest < Test::Unit::TestCase

  def setup
    File.delete(HelloWorker::TEST_FILE) if File.exist?(HelloWorker::TEST_FILE)
  end

  def teardown
    Sweatshop.instance_variable_set("@config", nil)
    Sweatshop.instance_variable_set("@queues", nil)
    File.delete(HelloWorker::TEST_FILE) if File.exist?(HelloWorker::TEST_FILE)
  end

  should "daemonize" do
    begin
      Sweatshop.config['enable'] = true
      Sweatshop.logger = :silent
  
      HelloWorker.async_hello('Amos')
  
      worker = File.expand_path(File.dirname(__FILE__) + '/hello_worker')
      sweatd = "#{File.dirname(__FILE__)}/../lib/sweatshop/sweatd.rb"
  
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

  should "connect to fallback servers if the default one is down" do
    begin
      Sweatshop.logger = :silent
      Sweatshop.config['enable'] = true
      Sweatshop.config['default']['cluster'] =
        [
         'localhost:5671', # invalid
         'localhost:5672'  # valid
        ]
      HelloWorker.async_hello('Amos')
  
      assert_equal 'Amos', HelloWorker.dequeue[:args].first

      HelloWorker.queue.client = nil

      HelloWorker.stop
      Sweatshop.config['default']['cluster'] =
        [
         'localhost:5671',# valid
         'localhost:5672' # invalid
        ]
  
      HelloWorker.async_hello('Amos')
      assert_equal 'Amos', HelloWorker.dequeue[:args].first
  
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
      fail "\n\n*** Functional test failed, is the rabbit server running on localhost? ***\n"
    end
  end

end
