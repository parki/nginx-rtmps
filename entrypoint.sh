#!/bin/sh
PORT=1936

genStunnelConf() {
  echo "[$1]"
  echo "client = yes"
  echo "accept = 127.0.0.1:$2"
  echo "connect = $1"
  echo "verifyChain = no"
  echo  
}

genNginxConf() {
  echo "daemon off;"
  echo "worker_processes auto;"
  echo "rtmp_auto_push on;"
  echo "events {}"
  echo "rtmp {"
  echo "    server {"
  echo "        listen $PORT;"
  echo "        listen [::]:$PORT ipv6only=on;"
  echo ""
  echo "        application $LOCAL_STREAM {"
  echo "            live on;"
  echo "            record off;"
  echo ""
  for U in $@; do
  echo "            push $U;"
  done
  echo "        }"
  echo "    }"
  echo "}"
}

if [ -z "$PORT" ]; then
  echo "PORT=[value] variable is required"
  exit 0
fi

if [ -z "$LOCAL_STREAM" ]; then
  echo "LOCAL_STREAM=[value] variable is required"
  exit 0
fi

if [ -z "$STREAMS" ]; then
  echo "STREAMS=[value] variable is required"
  exit 0
fi

TUNNELS=""
URLS=""
CMD=""
for A in $STREAMS; do
  if [ -n "$(echo "$A" | grep "rtmps://")" ]; then
    #handle RTMPS URL
    HOST=$(echo "$A" | cut -d/ -f3)
    if [ -n "$HOST" ]; then
      echo "$(genStunnelConf "$HOST" $PORT "$(echo "$A" | cut -d/ -f4-)")" >> /etc/stunnel/stunnel.conf

      URLS="$URLS rtmp://127.0.0.1:$PORT/$(echo "$A" | cut -d/ -f4-) "
      PORT=$(($PORT + 1))
    fi
  elif [ -n "$(echo "$A" | grep "rtmp://")" ]; then
    #handle RTMP URL
    URLS="$URLS $A "
  fi
done

genNginxConf "$URLS" > /usr/local/nginx/conf/nginx.conf

#start stunnel daemon
stunnel

exec "$@"
