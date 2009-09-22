require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/sweat_shop'

class SweatShopTest < Test::Unit::TestCase
  SweatShop.workers = []

  class HelloWorker < SweatShop::Worker
    def hello(name)
      "Hi, #{name}"
    end
  end

  class GroupedWorker < SweatShop::Worker
    queue_group :foo
  end

  should "group workers" do
    assert_equal [HelloWorker, GroupedWorker], SweatShop.workers_in_group(:all)
    assert_equal [HelloWorker],   SweatShop.workers_in_group(:default)
    assert_equal [GroupedWorker], SweatShop.workers_in_group(:foo)
  end

  should "synch call" do
    worker = HelloWorker.new
    assert_equal "Hi, Amos", worker.hello('Amos')
  end

  should "assign a uid" do
    SweatShop.logger = :silent
    SweatShop.config['enable'] = false
    uid = HelloWorker.async_hello('Amos')
    assert_not_nil uid
  end

  should "have before task" do
    HelloWorker.before_task do
      "hello"
    end
    assert_equal "hello", HelloWorker.before_task.call
  end

  should "have after task" do
    HelloWorker.after_task do
      "goodbye"
    end
    assert_equal "goodbye", HelloWorker.after_task.call
  end

  should "exception handler" do
    SweatShop.logger = :silent

    exception = nil
    HelloWorker.on_exception do |e|
      exception = e
    end

    HelloWorker.do_task(nil)
    assert_equal NoMethodError, exception.class
  end

  should "chain before tasks" do
    MESSAGES = []
    class BaseWorker < SweatShop::Worker
      before_task do |task|
        MESSAGES << 'base'
      end
    end
    class SubWorker < BaseWorker
      before_task do |task|
        MESSAGES << 'sub'
      end
    end
    SubWorker.call_before_task('foo')
    assert_equal ['base', 'sub'], MESSAGES
    SweatShop.workers.delete(BaseWorker)
    SweatShop.workers.delete(SubWorker)
  end
end
