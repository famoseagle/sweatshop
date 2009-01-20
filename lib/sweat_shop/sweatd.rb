# Rails environment
if File.exists?(File.dirname(__FILE__) + '/../../../../config/environment.rb')
  require File.dirname(__FILE__) + '/../../../../config/environment'
end
require File.dirname(__FILE__) + '/../sweat_shop'
require 'i_can_daemonize'

module SweatShop
  class Sweatd
    include ICanDaemonize
    queues = []
    groups = []

    arg '--queues=QUEUE,QUEUE', 'Optional queues (workers) to service. (Default is all)' do |value|
      queues = value.split(',').collect{|q| q.constantize}
    end

    arg '--groups=GROUP,GROUP', 'Optional groups of queues to service' do |value|
      groups = value.split(',').collect{|g| g.to_sym}
    end

    arg '--worker=WORKERFILE', 'Optional worker file to load'  do |value|
      require value
    end

    sig(:term) do
      EM.stop
    end
    
    sig(:int) do
      EM.stop 
    end

    daemonize do
      workers = []

      if groups.any?
        workers << SweatShop.workers_in_groups(groups)
      end

      if queues.any?
        workers << queues
      end

      if workers.any?
        puts "Starting #{workers.join(',')} ..." 
        SweatShop.complete_tasks(workers)
      else
        puts "Starting all workers..." 
        SweatShop.complete_all_tasks
      end
    end

  end
end
