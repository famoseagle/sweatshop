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
QUEUE_GROUPS=test
INSTANCES=3

export RAILS_ENV=dev

# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0

function start() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  echo -n $"Starting ${NAME}:${num} "
  if [ -z $QUEUE_GROUPS ]; then
    $DAEMON -d start --log-file $LOG_FILE --pid-file $PID_FILE 
  else
    $DAEMON -d start --log-file $LOG_FILE --pid-file $PID_FILE --groups $QUEUE_GROUPS
  fi
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

function stop() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  echo -n $"Stopping ${NAME}:${num}: "
  $DAEMON -d stop --log-file $LOG_FILE --pid-file $pidfile
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

function restart() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  echo -n $"Restarting ${NAME}:${num}: "
  $DAEMON -d restart --log-file $LOG_FILE --pid-file $pidfile
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

function zap() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  rm -f $pidfile
}

function doAll() {
  func=$1
  ii=0
  while [ "$ii" -lt $INSTANCES ] ; do
    eval "$func $(($ii))"
    ii=$(($ii + 1))
  done
}

case "$1" in
  start)
    doAll start
    ;;
  stop)
    doAll stop
    ;;
  restart)
    doAll restart
    ;;
  zap)
    doAll zap
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|zap}"
    exit 1
esac

exit $RETVAL
