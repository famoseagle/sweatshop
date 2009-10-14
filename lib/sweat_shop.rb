require 'rubygems'
require 'digest'
require 'yaml'

$:.unshift(File.dirname(__FILE__))
require 'message_queue/base'
require 'message_queue/rabbit'
require 'message_queue/kestrel'
require 'sweat_shop/worker'

module SweatShop
  extend self

  def workers
    @workers ||= []
  end

  def workers=(workers)
    @workers = workers 
  end

  def workers_in_group(groups)
    groups = [groups] unless groups.is_a?(Array)
    if groups.include?(:all)
      workers
    else
      workers.select do |worker|
        groups.include?(worker.queue_group)
      end
    end
  end

  def do_tasks(workers)
    if queue.subscribe?
      EM.run do
        workers.each do |worker|
          worker.subscribe
        end
      end
    else
      loop do
        wait = true
        workers.each do |worker|
          if task = worker.dequeue
            worker.do_task(task)
            wait = false
          end
        end
        if stop?
          workers.each do |worker|
            worker.stop
          end
          queue.stop
          exit 
        end
        sleep 1 if wait
      end
    end
  end

  def do_all_tasks
    do_tasks(
      workers_in_group(:all)
    )
  end

  def do_default_tasks
    do_tasks(
      workers_in_group(:default)
    )
  end

  def config
    @config ||= begin
      defaults = YAML.load_file(File.dirname(__FILE__) + '/../config/defaults.yml')
      if defined?(RAILS_ROOT)
        file = RAILS_ROOT + '/config/sweatshop.yml'
        if File.exist?(file)
          YAML.load_file(file)[RAILS_ENV || 'development']
        else
          defaults['enable'] = false
          defaults
        end
      else
        defaults
      end
    end
  end

  def stop
    @stop = true
    queue.stop if queue.subscribe?
  end

  def stop?
    @stop
  end

  def queue_sizes
    workers.inject([]) do |all, worker|
      all << [worker, worker.queue_size]
      all
    end
  end

  def queue(type = 'default')
    type = config[type] ? type : 'default'
    return queues[type] if queues[type]

    qconfig = config[type]
    qtype   = qconfig['queue'] || 'rabbit'
    queue   = constantize("MessageQueue::#{qtype.capitalize}")

    queues[type] = queue.new(qconfig)
  end

  def queue=(queue, type = 'default')
    queues[type] = queue
  end

  def queues
    @queues ||= {}
  end

  def queue_groups
    @queue_groups ||= workers.collect{|w| w.queue_group} << 'default'
  end

  def pp_sizes
    max_width = workers.collect{|w| w.to_s.size}.max
    puts '-' * (max_width + 10)
    puts queue_sizes.collect{ |p| sprintf("%-#{max_width}s %2s", p.first, p.last) }.join("\n")
    puts '-' * (max_width + 10)
  end

  def cluster_info
    servers = []
    queue_groups.each do |group|
      qconfig = config[group]
      next unless qconfig
      next unless qconfig['cluster']
      servers << qconfig['cluster']
    end
    servers.flatten!

    servers.each do |server|
      puts "\nQueue sizes on #{server}"
      queue = MessageQueue::Rabbit.new('host' => server)
      queue_groups.each do |group|
        queues[group] = queue
      end
      pp_sizes
      puts
    end
    @queues = {}
    nil
  end

  def log(msg)
    return if logger == :silent
    logger ? logger.debug(msg) : puts(msg)
  end

  def logger
    @logger
  end

  def logger=(logger)
    @logger = logger
  end

  def constantize(str)
    Object.module_eval("#{str}", __FILE__, __LINE__)
  end
end

if defined?(RAILS_ROOT)
  Dir.glob(RAILS_ROOT + '/app/workers/*.rb').each{|worker| require worker }
end
