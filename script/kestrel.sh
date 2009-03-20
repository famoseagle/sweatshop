#!/bin/sh
#
# chkconfig: 345 80 20
# description: kestrel is a light-weight queue written in scala
#

# Source function library.
if [ -f /etc/init.d/functions ] ; then
        . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ] ; then
        . /etc/rc.d/init.d/functions
else
        exit 0
fi  

prog=kestrel
USER=daemon
KESTREL_HOME=/opt/kestrel
VERSION=1.0
JAR=$KESTREL_HOME/kestrel-$VERSION.jar

if [ ! -r $JAR ]; then
  echo "FAIL"
  echo "*** jar missing - not starting"
  exit 1
fi

PIDFILE=/var/run/${prog}.pid
LOCKFILE=/var/lock/subsys/$prog

HEAP_OPTS="-Xmx2048m -Xms1024m -XX:NewSize=256m"
JAVA_OPTS="-server -verbosegc -XX:+PrintGCDetails -XX:+UseConcMarkSweepGC -XX:+UseParNewGC $HEAP_OPTS"

start() {
  echo -n $"Starting $prog: "
  java $JAVA_OPTS -jar $JAR > /var/log/$prog-startup.log 2>&1 & 
  RETVAL=$?
  if [ $RETVAL -eq 0 ]; then
    echo $! > $PIDFILE
    success $"$prog startup"
    touch $LOCKFILE
  else
    failure $"$prog startup"
  fi
  echo
  return $RETVAL;
}

stop() {
  echo -n $"Stopping $prog: "
  if [ -f $PIDFILE ]; then
    killproc -p $PIDFILE $prog
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
      rm -f $LOCKFILE
      rm -f $PIDFILE
    fi;
  else
    RETVAL=1
    failure;
  fi
  echo
  return $RETVAL;
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
      start
      ;;

  condrestart)
      if [ -f $LOCKFILE ]; then
          stop
          start
      fi
      ;;

  *)
      echo $"Usage: $0 {start|stop|restart|condrestart}"
      exit 1
esac

exit $RETVAL
