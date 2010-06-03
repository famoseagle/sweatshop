require File.expand_path(File.dirname(__FILE__) + '/../lib/sweatshop')
require File.expand_path(File.dirname(__FILE__) + '/test_helper'     )
require File.expand_path(File.dirname(__FILE__) + '/hello_worker'    )

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
    enable_server do
      HelloWorker.async_hello('Amos')
  
      worker = File.expand_path(File.dirname(__FILE__) + '/hello_worker')
      sweatd = "#{File.dirname(__FILE__)}/../lib/sweatshop/sweatd.rb"
  
      `ruby #{sweatd} --worker-file #{worker} start`
      `ruby #{sweatd} stop`
  
      File.delete('sweatd.log') if File.exist?('sweatd.log')
      assert_equal 'Hi, Amos', File.read(HelloWorker::TEST_FILE)
    end
  end

  should "connect to fallback servers if the default one is down" do
    enable_server do
      Sweatshop.config['default']['cluster'] =
        [
         'localhost:5671', # invalid
         'localhost:5672'  # valid
        ]
      HelloWorker.async_hello('Amos')
      task = HelloWorker.dequeue
      assert_equal 'Amos', task[:args].first

      HelloWorker.queue.client = nil

      HelloWorker.stop
      Sweatshop.config['default']['cluster'] =
        [
         'localhost:5671',# valid
         'localhost:5672' # invalid
        ]
  
      HelloWorker.async_hello('Amos')
      assert_equal 'Amos', HelloWorker.dequeue[:args].first
    end
  end

  should "exception handler" do
    exception = nil
    HelloWorker.on_exception do |e|
      exception = e
    end

    HelloWorker.do_task(nil)
    assert_equal NoMethodError, exception.class
  end


  def enable_server
    Sweatshop.config['enable'] = true
    Sweatshop.logger = :silent
    begin
      yield
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
      fail "\n\n*** Functional test failed, is the rabbit server running on localhost? ***\n"
    end
  end
end
