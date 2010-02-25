module MessageQueue
  class Base
    attr_reader :opts
    def queue_size(queue);    end
    def enqueue(queue, data); end
    def dequeue(queue);       end
    def confirm(queue);       end
    def delete(queue);        end
    def client;               end
    def stop;                 end
    def flush_all(queue);     end
  end
end
