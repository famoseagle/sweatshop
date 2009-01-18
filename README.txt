= sweat-shop

== DESCRIPTION:

Sweatshop is as simple asynchronous worker queue built on top of
rabbitmq/ampq. Inspired by Workling, it follows some of the same patterns with a few tweaks.

== FEATURES/PROBLEMS:

* async message passing through amq
* ability to group workers into specific queues
* can work on webservers not running EventMachine like Passenger

== SYNOPSIS:

== REQUIREMENTS:

* amq
* i_can_daemonize

== INSTALL:

  sudo gem install sweat_shop

== LICENSE:

Copyright (c) 2009 Amos Elliston, Geni.com; Published under The MIT License, see License.txt
