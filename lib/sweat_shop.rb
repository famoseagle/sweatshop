require 'rubygems'
require 'digest'
require 'yaml'

#require File.dirname(__FILE__) + '/../../memcache/lib/memcache'
require File.dirname(__FILE__) + '/../../../memcache/lib/memcache_extended'
require File.dirname(__FILE__) + '/../../../memcache/lib/memcache_util'

$:.unshift(File.dirname(__FILE__))
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
    loop do
      wait = true
      workers.each do |worker|
        if task = worker.pop
          worker.do_task(task)
          wait = false
        end
      end
      exit if stop?
      sleep 0.25 if wait
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

  def stop!
    @stop = true
  end

  def stop?
    @stop
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

  def queue
    @queue ||= MemCache.new('localhost:22133')
    # @queue ||= MemCache::Server.new(:host => config[:host], :port => config[:port])
  end

  def queue=(queue)
    @queue = queue
  end
end

if defined?(RAILS_ROOT)
  Dir.glob(RAILS_ROOT + '/app/workers/*.rb').each{|worker| require worker }
  SweatShop::Worker.logger = RAILS_DEFAULT_LOGGER
end
