require File.dirname(__FILE__) + '/../../../carrot/lib/carrot'
module MessageQueue
  class Rabbit < Base

    def initialize(opts={})
      @servers = opts[:servers]
      @info = {}
      @host, @port = @servers.first.split(':')
      @port = @port.to_i
    end

    def delete(queue)
      client.queue(queue).delete
    end

    def queue_size(queue)
      client.queue(queue).message_count
    end

    def enqueue(queue, data)
      client.queue(queue, :durable => true).publish(Marshal.dump(data), :persistent => true)
    end

    def dequeue(queue)
      task = client.queue(queue).pop(:ack => true)
      return unless task
      Marshal.load(task)
    end

    def confirm(queue)
      client.queue(queue).ack
    end

    def client
      @client ||= Carrot.new(:host => @host, :port => @port) 
    end

    def stop
      client.stop
    end
  end
end
