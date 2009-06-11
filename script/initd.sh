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
PID_DIR=/opt/current/log
LOG_FILE=$PID_DIR/sweatshop.log
INSTANCES=3
#QUEUE_GROUPS=test
export RAILS_ENV=dev

[ -f /etc/sysconfig/${NAME} ] && . /etc/sysconfig/${NAME}


# Gracefully exit if the package has been removed.
if [ ! -x $DAEMON ]; then
  echo "$DAEMON does not exist"
  exit 0
fi;


function start() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  echo $"Starting ${NAME}:${num} "
  if [ -z $QUEUE_GROUPS ]; then
    $DAEMON -d start --log-file $LOG_FILE --pid-file $pidfile 
  else
    $DAEMON -d start --log-file $LOG_FILE --pid-file $pidfile --groups $QUEUE_GROUPS
  fi
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

function stop() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  echo $"Stopping ${NAME}:${num}: "
  $DAEMON -d stop --log-file $LOG_FILE --pid-file $pidfile
  RETVAL=$?
  [ $RETVAL -eq 0 ] && success || failure
  echo
  return $RETVAL
}

function reload() {
  num=$1
  pidfile=$PID_DIR/$NAME.$num.pid
  echo $"Reloading ${NAME}:${num}: "
  $DAEMON -d reload --log-file $LOG_FILE --pid-file $pidfile
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
    doAll stop
    sleep 1
    doAll start
    ;;
  reload)
    doAll reload
    ;;
  zap)
    doAll zap
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|reload|zap}"
    exit 1
esac

exit $RETVAL
