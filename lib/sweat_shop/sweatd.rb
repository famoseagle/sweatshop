require File.dirname(__FILE__) + '/../sweat_shop'
require 'i_can_daemonize'

module SweatShop
  class Sweatd
    include ICanDaemonize
    queues     = []
    groups     = []
    rails_root = nil

    arg '--workers=Worker,Worker', 'Workers to service (Default is all)' do |value|
      queues = value.split(',')
    end

    arg '--groups=GROUP,GROUP', 'Groups of queues to service' do |value|
      groups = value.split(',').collect{|g| g.to_sym}
    end

    arg '--worker-file=WORKERFILE', 'Worker file to load'  do |value|
      require value
    end

    arg '--worker-dir=WORKERDIR', 'Directory containing workers'  do |value|
      Dir.glob(value + '*.rb').each{|worker| require worker}
    end

    arg '--rails=DIR', 'Pass in RAILS_ROOT to run this daemon in a rails environment' do |value|
      rails_root = value
    end

    sig(:term) do
      EM.stop
    end
    
    sig(:int) do
      EM.stop 
    end

    before do
      return unless rails_root
      puts "Loading Rails..."
      require rails_root + '/config/environment' 
    end

    daemonize(:kill_timeout => 20) do
      workers = []

      if groups.any?
        workers += SweatShop.workers_in_group(groups)
      end

      if queues.any?
        workers += queues.collect{|q| Object.module_eval(q)}
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
