require File.dirname(__FILE__) + '/../../../memcache/lib/memcache_mock'
require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/sweat_shop'

class SweatShopTest < Test::Unit::TestCase
  SweatShop.workers = []
  SweatShop.queue   = Kestrel.new(:client => MemCacheMock.new)

  class HelloWorker < SweatShop::Worker
    def hello(name)
      "Hi, #{name}"
    end
  end

  class GroupedWorker < SweatShop::Worker
    queue_group :foo
  end

  test "group workers" do
    assert_equal [HelloWorker, GroupedWorker], SweatShop.workers_in_group(:all)
    assert_equal [HelloWorker],   SweatShop.workers_in_group(:default)
    assert_equal [GroupedWorker], SweatShop.workers_in_group(:foo)
  end

  test "synch call" do
    worker = HelloWorker.new
    assert_equal "Hi, Amos", worker.hello('Amos')
  end

  test "uid" do
    SweatShop::Worker.logger = :silent
    uid = HelloWorker.async_hello('Amos')
    assert_not_nil uid
  end

  test "before task" do
    HelloWorker.before_task do
      "hello"
    end
    assert_equal "hello", HelloWorker.before_task.call
  end

  test "after task" do
    HelloWorker.after_task do
      "goodbye"
    end
    assert_equal "goodbye", HelloWorker.after_task.call
  end

  test "chainable before tasks" do
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
