require File.dirname(__FILE__) + '/metaid'

module SweatShop
  class Worker
    @@logger = nil

    def self.inherited(subclass)
      self.workers << subclass
    end

    def self.method_missing(method, *args, &block)
      if method.to_s =~ /^async_(.*)/ and config['enable']
        method        = $1
        expected_args = instance.method(method).arity
        if expected_args != args.size 
          raise ArgumentError.new("#{method} expects #{expected_args} arguments")
        end

        uid  = ::Digest::MD5.hexdigest("#{name}:#{method}:#{args}:#{Time.now.to_f}")
        task = {:args => args, :method => method, :uid => uid, :queued_at => Time.now.to_i}

        log("Putting #{uid} on #{queue_name}")
        enqueue(task)

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

    def self.config
      SweatShop.config
    end

    def self.queue_name
      @queue_name ||= self.to_s
    end

    def self.queue_size
      queue.queue_size(queue_name)
    end

    def self.enqueue(task)
      queue.enqueue(queue_name, task)
    end

    def self.dequeue
      queue.dequeue(queue_name)
    end

    def self.confirm
      queue.confirm(queue_name)
    end
    
    def self.do_tasks
      while task = dequeue
        do_task(task)
      end
    end

    def self.do_task(task)
      call_before_task(task)

      queued_at = task[:queued_at] ? "(queued #{Time.at(task[:queued_at]).strftime('%Y/%m/%d %H:%M:%S')})" : ''
      log("Dequeuing #{queue_name}::#{task[:method]} #{queued_at}")
      task[:result] = instance.send(task[:method], *task[:args])

      call_after_task(task)
      confirm
    end

    def self.call_before_task(task)
      superclass.call_before_task(task) if superclass.respond_to?(:call_before_task)
      before_task.call(task) if before_task
    end

    def self.call_after_task(task)
      superclass.call_after_task(task) if superclass.respond_to?(:call_after_task)
      after_task.call(task) if after_task
    end

    def self.workers
      SweatShop.workers
    end

    def self.log(msg)
      return if logger == :silent
      logger ? logger.debug(msg) : puts(msg)
    end

    def self.logger
      @@logger
    end

    def self.logger=(logger)
      @@logger = logger
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

    def self.queue
      SweatShop.queue
    end

    def self.queue_group(group=nil)
      group ? meta_def(:_queue_group){ group } : _queue_group
    end
    queue_group :default
  end
end
