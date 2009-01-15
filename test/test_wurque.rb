require File.dirname(__FILE__) + '/test_helper'

class WurqueTest < Test::Unit::TestCase

  class SimpleWorker < Wurque
    def hello(name)
      "Hi, #{name}"
    end
  end

  class GroupedWorker < Wurque
    queue_group :foo
  end

  test "group workers" do
    assert_equal [SimpleWorker, GroupedWorker], Wurque.workers_in_group(:all)
    assert_equal [SimpleWorker], Wurque.workers_in_group(:default)
    assert_equal [GroupedWorker], Wurque.workers_in_group(:foo)
  end

  test "basic" do
    worker = SimpleWorker.new
    assert_equal "Hi, Amos", worker.hello('Amos')
  end

  test "uid" do
    uid = SimpleWorker.async_hello('Amos')
    assert_not_nil uid
  end

end
