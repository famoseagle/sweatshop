module MessageQueue
  class Base
    attr_reader :servers
    def queue_size(queue);    end
    def enqueue(queue, data); end
    def dequeue(queue);       end
    def confirm(queue);       end
    def subscribe(queue);     end
    def client;               end
    def stop;                 end

    def subscribe?
      false
    end
  end
end
