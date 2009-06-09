require File.dirname(__FILE__) + '/../lib/sweat_shop'
class HelloWorker < SweatShop::Worker
  TEST_FILE = File.dirname(__FILE__) + '/test.txt' unless defined?(TEST_FILE)

  def hello(name)
    puts name
    "Hi, #{name}"
  end

  after_task do |task|
    File.open(TEST_FILE, 'w'){|f| f << task[:result]}
  end
end
