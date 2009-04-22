require 'mq'
module MessageQueue
  class Rabbit < Base
    attr_accessor :em_thread

    def initialize(opts={})
      @servers = opts['servers']
      @info = {}
      @host, @port = @servers.first.split(':')
      @port = @port.to_i
    end

    def queue_size(queue)
      num = 0
      client.queue(queue).status{|messages, consumers| num = messages}
      num
    end

    def enqueue(queue, data)
      client.queue(queue, :durable => true).publish(Marshal.dump(data), :persistent => true)
    end

    def dequeue(queue)
      client.queue(queue).pop do |info, task|
        @info[queue] = info
        return Marshal.load(task)
      end
    end

    def confirm(queue)
      if @info[queue] 
        @info[queue].ack
        @info[queue] = nil
      end
    end

    def client
      @client ||= begin 
        start_em
        if servers
          MQ.new(AMQP.connect(:host => @host, :port => @port)) 
        else
          MQ.new
        end
      end
    end

    def start_em
      if em_thread.nil? and not EM.reactor_running?
        self.em_thread = Thread.new{EM.run}
        ['INT', 'TERM'].each do |sig|
          old = trap(sig) do 
            stop
            old.call
          end
        end
      end
    end

    def subscribe?
      true
    end

    def subscribe(queue, &block)
      AMQP.start(:host => @host, :port => @port) do
        mq = MQ.new
        mq.send(AMQP::Protocol::Basic::Qos.new(:prefetch_size => 0, :prefetch_count => 1, :global => false))
        mq.queue(queue, :durable => true).subscribe(:ack => true) do |info, task|
          if task
            @info[queue] = info
            task = Marshal.load(task)
            block.call(task)
          end
        end
      end
    end

    def stop
      em_thread.join(0.15) unless em_thread.nil?
      AMQP.stop{ EM.stop }
    end
  end
end
