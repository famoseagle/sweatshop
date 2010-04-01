require File.dirname(__FILE__) + '/metaid'

module Sweatshop
  class Worker
    def self.inherited(subclass)
      self.workers << subclass
    end

    def self.method_missing(method, *args, &block)
      if method.to_s =~ /^async_(.*)/
        method = $1
        check_arity!(instance.method(method), args)

        return instance.send(method, *args) unless async?

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

    def self.async?
      Sweatshop.enabled?
    end

    def self.instance
      @instance ||= new
    end

    def self.config
      Sweatshop.config
    end

    def self.queue_name
      @queue_name ||= self.to_s
    end

    def self.flush_queue
      queue.flush_all(queue_name)
    end

    def self.delete_queue
      queue.delete(queue_name)
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
      begin
        call_before_task(task)

        queued_at = task[:queued_at] ? "(queued #{Time.at(task[:queued_at]).strftime('%Y/%m/%d %H:%M:%S')})" : ''
        log("Dequeuing #{queue_name}::#{task[:method]} #{queued_at}")
        task[:result] = instance.send(task[:method], *task[:args])

        call_after_task(task)
        confirm
      rescue SystemExit
        exit
      rescue Exception => e
        log("Caught Exception: #{e.message}, \n#{e.backtrace.join("\n")}")
        call_exception_handler(e)

        # the only way to re-queue messages with rabbitmq is to close and reopen the connection
        # putting a 'sleep 2' in here to give the administrator to fix peristent problems, otherwise
        # we'll hit an infinite loop
        #
        # THIS CODE IS PROBLEMATIC --- we need to put these tasks into a 'failed' queue so we don't run into infinite loops
        # will just 'confirm' for now
        #queue.stop
        #sleep 2
        confirm
      end
    end

    def self.queue=(queue)
      @queue = queue
    end

    def self.queue
      @queue ||= Sweatshop.queue(queue_group.to_s)
    end

    def self.workers
      Sweatshop.workers
    end

    def self.config
      Sweatshop.config
    end

    def self.log(msg)
      Sweatshop.log(msg)
    end

    def self.call_before_task(task)
      superclass.call_before_task(task) if superclass.respond_to?(:call_before_task)
      before_task.call(task) if before_task
    end

    def self.call_after_task(task)
      superclass.call_after_task(task) if superclass.respond_to?(:call_after_task)
      after_task.call(task) if after_task
    end

    def self.call_exception_handler(exception)
      superclass.call_exception_handler(exception) if superclass.respond_to?(:call_exception_handler)
      on_exception.call(exception) if on_exception
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

    def self.on_exception(&block)
      if block
        @on_exception = block
      else
        @on_exception
      end
    end

    def self.stop
      instance.stop
    end

    # called before we exit -- subclass can implement this method
    def stop; end;


    def self.queue_group(group=nil)
      group ? meta_def(:_queue_group){ group } : _queue_group
    end
    queue_group :default
  end
end
