class Kestrel
  attr_reader :client, :servers

  def initialize(opts)
    @servers = opts[:servers]
    @client  = opts[:client] || MemCache.new(@servers) 
  end

  def queue_size(queue)
    size  = 0
    stats = client.stats
    servers.each do |server|
      size += stats[server]["queue_#{queue}_items"].to_i
    end
    size
  end

  def enqueue(queue, data)
    client.set(queue, data)
  end

  def dequeue(queue)
    client.get("#{queue}/open")
  end

  def confirm(queue)
    client.get("#{queue}/close")
  end
end
