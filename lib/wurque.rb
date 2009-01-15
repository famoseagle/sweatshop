require 'rubygems'
require 'mq'
require 'digest'

def metaclass; class << self; self; end; end
def meta_eval &blk; metaclass.instance_eval &blk; end
def meta_def name, &blk
  meta_eval { define_method name, &blk }
end

class Wurque
  cattr_accessor :workers, :em_thread

  @@workers      = []
  @@mq           = nil
  @@em_thread    = nil
  @@before_tasks = {}
  @@after_tasks  = {}

  class << self
    def inherited(subclass)
      self.workers << subclass
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^async_(.*)/
        self.em_thread = Thread.new{EM.run} if em_thread.nil? and not EM.reactor_running?
        method = $1
        uid    = ::Digest::MD5.hexdigest("#{self.name}:#{method}:#{args}:#{Time.now.to_f}")
        data   = Marshal.dump({:args => args, :method => method, :uid => uid})
        mq.queue(queue_name).publish(data, :durable => true)
        uid
      else
        super
      end
    end

    def mq
      @@mq ||= begin
        @@mq = MQ.new
      end
    end

    def cleanup
      em_thread.join(0.15) unless em_thread.nil?
    end

    def queue_name
      @queue_name ||= self.to_s.dasherize
    end

    def complete_tasks(workers=[])
      EM.run do
        if workers.any?
          workers.uniq.each do |worker|
            subscribe(worker)
          end
        else
          subscribe(self)
        end
      end
    end

    def subscribe(worker)
      instance = worker.new
      mq.queue(worker.queue_name).subscribe do |data|
        data = Marshal.load(data)
        @@before_tasks[worker].call(data) if @@before_tasks[worker]
        logger.debug("Dequeuing #{data[:method]}")
        data[:result] = instance.send(data[:method], *data[:args]) 
        @@after_tasks[worker].call(data) if @@after_tasks[worker]
      end
    end

    def workers_in_groups(groups)
      groups = [groups] unless groups.is_a?(Array)
      if groups.include?(:all)
        workers
      else
        workers.select do |worker|
          groups.include?(worker.queue_group)
        end
      end
    end

    def complete_all_tasks
      complete_tasks(
        workers_in_groups(:all)
      )
    end

    def complete_default_tasks
      complete_tasks(
        workers_in_groups(:default)
      )
    end

    def logger
      RAILS_DEFAULT_LOGGER
    end

    def before_task(&block)
      @@before_tasks[self] = block
    end

    def after_task(&block)
      @@after_tasks[self] = block
    end

    def queue_group(group=nil)
      group ? meta_def(:_group){ group } : _group
    end
  end
  queue_group :default
end

Signal.trap('INT') do 
  AMQP.stop{ EM.stop } 
  Wurque.cleanup
end

Signal.trap('TERM') do 
  AMQP.stop{ EM.stop } 
  Wurque.cleanup
end

load_path = File.expand_path(File.join(RAILS_ROOT, 'app', 'workers'))
Dir.glob("#{load_path}/**/*.rb").each{|worker| require worker }
