module SweatShop
  class Worker
    @@mq           = nil
    @@em_thread    = nil

    def self.inherited(subclass)
      self.workers << subclass
    end

    def self.method_missing(method, *args, &block)
      if method.to_s =~ /^async_(.*)/
        method        = $1
        expected_args = instance.method(method).arity
        
        if expected_args != args.size 
          raise ArgumentError.new("#{method} expects #{expected_args} arguments")
        end

        uid     = ::Digest::MD5.hexdigest("#{self.name}:#{method}:#{args}:#{Time.now.to_f}")
        payload = Marshal.dump({:args => args, :method => method, :uid => uid})
        log("Putting #{uid} on #{queue_name}")

        self.em_thread = Thread.new{EM.run} if em_thread.nil? and not EM.reactor_running?
        mq.queue(queue_name).publish(payload, :durable => true)
        uid
      elsif instance.respond_to?(method)
        instance.send(method, *args)
      else
        super
      end
    end

    def self.instance
      @instance ||= new
    end

    def self.mq
      @@mq ||= begin
        @@mq = MQ.new
      end
    end

    def self.cleanup
      em_thread.join(0.15) unless em_thread.nil?
    end

    def self.queue_name
      @queue_name ||= self.to_s
    end

    def self.complete_tasks
      EM.run do
        mq.queue(queue_name).subscribe do |payload|
          task = Marshal.load(payload)
          before_task.call(task) if before_task
          log("Dequeuing #{task[:method]}")
          task[:result] = instance.send(task[:method], *task[:args]) 
          after_task.call(task)  if after_task
        end
      end
    end

    def self.workers
      SweatShop.workers
    end

    def self.log(msg)
      logger ? logger.debug(msg) : puts(msg)
    end

    def self.logger
      defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER
    end

    def self.before_task(&block)
      if block
        @before_task = block
      else
        @before_task
      end
    end

    def self.after_task(&block)
      if block
        @after_task = block
      else
        @after_task
      end
    end

    def self.em_thread
      @@em_thread
    end

    def self.em_thread=(thread)
      @@em_thread = thread
    end

    def self.queue_group(group=nil)
      group ? meta_def(:_queue_group){ group } : _queue_group
    end
    queue_group :default

    Signal.trap('INT') do 
      EM.stop
      cleanup
    end

    Signal.trap('TERM') do 
      EM.stop 
      cleanup
    end
  end
end
