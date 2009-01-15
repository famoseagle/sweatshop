require File.dirname(__FILE__) + '/test_helper'

class WurqueTest < Test::Unit::TestCase

  class SimpleWorker < Wurque
    def hello(name)
      "Hi, #{name}"
    end
  end

  test "complete tasks" do
    EM.run do
      mq = MQ.new
      mq.queue(SimpleWorker.queue_name).publish('foo')
      uid = SimpleWorker.async_hello('Amos')
    end
    #--------------------------------------------------
    # SimpleWorker.complete_tasks
    # assert_equal '', SimpleWorker.cache[uid]
    #-------------------------------------------------- 
  end

  #--------------------------------------------------
  # require 'rubygems'
  # require 'pp'
  # require 'mq'
  # EM.run do
  #   q = MQ.new
  #   q.queue('WurqueTest::SimpleWorker').subscribe{|d| pp d}
  # end
  #-------------------------------------------------- 
                
  
end
