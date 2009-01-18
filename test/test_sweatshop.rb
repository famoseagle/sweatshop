require File.dirname(__FILE__) + '/test_helper'

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
end
