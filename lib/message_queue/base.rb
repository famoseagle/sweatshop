module MessageQueue
  class Base
    attr_reader :servers
    def queue_size(queue);    end
    def enqueue(queue, data); end
    def dequeue(queue);       end
    def confirm(queue);       end
    def client;               end
  end
end
