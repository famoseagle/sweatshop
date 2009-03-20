require File.dirname(__FILE__) + '/../../../amqp/lib/mq'
module MessageQueue
  class Rabbit < Base
    def initialize(opts={})
      @servers = opts[:servers]
      @info = {}
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
        return task
      end
    end

    def confirm
      @info[queue] && @info[queue].ack
    end

    def client
      @client ||= begin 
        if servers
          host, port = servers.first.split(':')
          MQ.new(AMQP.connect(:host => host, :port => port.to_i)) 
        else
          MQ.new
        end
      end
    end
  end
end
