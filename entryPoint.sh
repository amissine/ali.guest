#!/bin/bash

# Locals {{{1
ID="$1"
IP="$2"
URL="${ID}@${IP}" # guest@ubuntu
LOG='/root/syslog' # 'logfile' # or /root/syserr
IN='/root/infile'
FEED='/umf/feed' # the Unified Market Feed from the server

ali_remote_port_forwarding () { # {{{1
  local port 

  ( sleep 5; port=`cat $LOG | head -n 1 | awk '{ print $3}'`; export P=$port; ssh $1 "echo $P >> rData" ) &
  rm -f $IN; touch $IN
  tail -f $IN | ssh -R 0:127.0.0.1:22 $1 'read; echo $REPLY'
}

onSIGINT () { # {{{1
  echo -e '\a\n- exiting on SIGINT, LOG so far:'; cat $LOG; echo -e 'done\ndone\n' > $IN; sleep 2
  exit 0
}

progress_report () { # {{{1
  while true; do read || break # ignore $REPLY
    echo -en "- received Unified Market Feed on $(date)\r"
  done
}

service ssh restart; sleep 1; service ssh status # {{{1

trap onSIGINT SIGINT
echo "--- $(date) - started receiving Unified Market Feed from $URL" >> $FEED
( sleep 10; tail -n 1 -f $FEED | progress_report ) &

echo "- connecting to $URL..."
ssh-keyscan "$IP" 2>/dev/null | grep 'ed25519' > /root/.ssh/known_hosts
ali_remote_port_forwarding $URL 2>$LOG
