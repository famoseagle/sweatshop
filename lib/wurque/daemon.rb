require 'i_can_daemonize'

class Wurque
  class Daemon
    include ICanDaemonize
    arg :queues, 'Optional queues (workers) to service. (Default is all)' do |arg|
      arg.split(',').collect{|q| q.constantize}
    end

    arg :groups, 'Optional groups of queues to service' do |arg|
      arg.split(',').collect{|g| g.to_sym}
    end

    daemonize do
      workers = []
      if groups
        workers << Wurque.workers_in_groups(groups)
      end

      if queues
        workers << queues
      end

      if workers.any?
        Wurque.complete_tasks(workers)
      else
        Wurque.complete_all_tasks
      end
    end

  end
end
