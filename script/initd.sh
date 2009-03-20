#!/bin/bash

# chkconfig: 345 80 20
# description: Sweatshop starts the sweatd daemon

# Source function library.
if [ -f /etc/init.d/functions ] ; then
	. /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ] ; then
	. /etc/rc.d/init.d/functions
else
	exit 0
fi

DAEMON=/opt/current/script/sweatshop
NAME=sweatshop
LOG_FILE=/opt/log/sweatshop.log
PID_FILE=/opt/log/sweatshop.pid
QUEUE_GROUPS=test
INSTANCES=3

export RAILS_ENV=dev

# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0

start() {
  echo -n $"Starting ${NAME}: "
  if [ -z $QUEUE_GROUPS ]; then
    $DAEMON -d start --log-file $LOG_FILE --pid-file $PID_FILE --instances $INSTANCES
  else
    $DAEMON -d start --log-file $LOG_FILE --pid-file $PID_FILE --instances $INSTANCES --groups $QUEUE_GROUPS
  fi
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

stop() {
  echo -n $"Stopping ${NAME}: "
  $DAEMON -d stop --log-file $LOG_FILE --pid-file $PID_FILE --instances $INSTANCES
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    sleep 3
    start
    RETVAL=$?
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit $RETVAL
