require 'carrot'
module MessageQueue
  class Rabbit < Base

    def initialize(opts={})
      @opts = opts
    end

    def delete(queue)
      send_command do
        client.queue(queue).delete
      end
    end

    def queue_size(queue)
      send_command do
        client.queue(queue).message_count
      end
    end

    def enqueue(queue, data)
      send_command do
        client.queue(queue, :durable => true).publish(Marshal.dump(data), :persistent => true)
      end
    end

    def dequeue(queue)
      send_command do
        task = client.queue(queue).pop(:ack => true)
        return unless task
        Marshal.load(task)
      end
    end

    def confirm(queue)
      send_command do
        client.queue(queue).ack
      end
    end

    def flush_all(queue)
      send_command do
        client.queue(queue).purge
      end
    end

    def send_command(&block)
      retried = false
      begin
        block.call
      rescue Carrot::AMQP::Server::ServerDown => e
        if not retried
          Sweatshop.log "Error #{e.message}. Retrying..."
          @client = nil
          retried = true
          retry
        else
          raise e
        end
      end
    end

    def client
      return @client if @client

      if @opts['cluster']
        @opts['cluster'].each_with_index do |server, i|
          host, port = server.split(':')
          begin
            @client = Carrot.new(
              :host   => host,
              :port   => port.to_i,
              :user   => @opts['user'],
              :pass   => @opts['pass'],
              :vhost  => @opts['vhost'],
              :insist => @opts['insist']
            )
            return @client
          rescue Carrot::AMQP::Server::ServerDown => e
            if i == (@opts['cluster'].size-1)
              raise e
            else
              Sweatshop.log "\n*** Sweatshop failing over to #{@opts['cluster'][i+1]} ***"
              Sweatshop.log "Error: #{e.message}\n#{e.backtrace.join("\n")}"
              next
            end
          end
        end
      else
        if @opts['host'] =~ /:/
          host, port = @opts['host'].split(':')
        else
          host = @opts['host']
          port = @opts['port']
        end
        @client = Carrot.new(
          :host   => host,
          :port   => port.to_i,
          :user   => @opts['user'],
          :pass   => @opts['pass'],
          :vhost  => @opts['vhost'],
          :insist => @opts['insist']
        )
      end
      @client
    end

    def client=(client)
      @client = client
    end

    def stop
      client.stop
    end
  end
end
