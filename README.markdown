# SweatShop

SweatShop provides an api to background resource intensive tasks. Much of the api design was copied from Workling, with a few tweaks.
Currently, it runs kestrel, but it can support any number of queues.

## Installing 

   gem install sweat_shop
   freeze in your rails directory
   cd vendor/gems/sweat_shop
   rake setup

## Writing workers

Put `email_worker.rb` into app/workers and sublcass `SweatShop::Worker`:

    class EmailWorker
      def send_mail(to)
        user = User.find_by_id(to)
        Mailer.deliver_welcome(to)
      end
    end

Then, anywhere in your app you can execute:

    EmailWorker.async_send_mail(1)

The `async` signifies that this task will be placed on a queue to be serviced by the EmailWorker possibly on another machine. You can also
call:

    EmailWorker.send_mail(1)

That will do the work immediately, without placing the task on the queue. You can also define a `queue_group` at the top of the file
which will allow you to split workers out into logical groups. This is important if you have various machines serving different
queues. 

## Running the queue

SweatShop has been tested with Kestrel, but it will also work with Starling. You can install and start kestrel following the instructions here:

(http://github.com/robey/kestrel/tree/master)

config/sweatshop.yml specifies the machine address of the queue (default localhost:22133).

## Running the workers

Assuming you ran `rake setup` in Rails, you can type:

    script/sweatshop

By default, the script will run all workers defined in the app/workers dir. Every task will be processed on each queue using a round-robin algorithm. You can also add the `-d` flag which will put the worker in daemon mode. The daemon also takes other params.  Add a `-h` for more details.

    script/sweatshop -d
    script/sweatshop -d stop

If you would like to run SweatShop as a daemon on a linux machine, use the initd.sh script provided in the sweat_shop/script dir.

# REQUIREMENTS

    i_can_daemonize
    memcache (for kestrel)

# LICENSE

Copyright (c) 2009 Amos Elliston, Geni.com; Published under The MIT License, see License
