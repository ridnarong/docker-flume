#!/bin/bash

set -m

# Get config env
sources_env=$(compgen -A variable | grep FLUME_SOURCES_)
sinks_env=$(compgen -A variable | grep FLUME_SINKS_)
channels_env=$(compgen -A variable | grep FLUME_CHANNELS_)

#Prepare config file


if [ ! -f /opt/flume/conf/.auto ]; then
  conf_file="/dev/null"
else
  conf_file="/opt/flume/conf/my.conf"
fi
cat > $conf_file <<- EOM
a1.sources = r1
a1.sinks = k1
a1.channels = c1
EOM

for r in $sources_env; do
  substring=${r:14}
  key=$(echo $substring | tr '[:upper:]' '[:lower:]' | cut -d'_' -f 1)
  numbers=$(($(grep -o "_" <<< "$r" | wc -l)-1))
  for (( i = 1; i < $numbers; i++ )); do
    echo $substring | tr '[:upper:]' '[:lower:]' | cut -d'_' -f $i
  done
  numbers=$(grep -o "_" <<< "$r" | wc -l)
  for (( i = 2; i < $numbers; i++ )); do
    foo=$(echo $substring | cut -d'_' -f $i)
    len=${#foo}
    if [ $len -eq 0 ]; then
      ((i=i+1))
      foo=$(echo $substring | cut -d'_' -f $i)
      key="$key.$(tr '[:upper:]' '[:lower:]' <<< $foo)"
    else
      key="$key${foo:0:1}$(tr '[:upper:]' '[:lower:]' <<< ${foo:1})"
    fi
  done
  echo "a1.sources.r1.$key = ${!r}" >> $conf_file
done
for r in $sinks_env; do
  substring=${r:12}
  key=$(echo $substring | tr '[:upper:]' '[:lower:]' | cut -d'_' -f 1)
  numbers=$(grep -o "_" <<< "$r" | wc -l)
  for (( i = 2; i < $numbers; i++ )); do
    foo=$(echo $substring | cut -d'_' -f $i)
    len=${#foo}
    if [ $len -eq 0 ]; then
      ((i=i+1))
      foo=$(echo $substring | cut -d'_' -f $i)
      key="$key.$(tr '[:upper:]' '[:lower:]' <<< $foo)"
    else
      key="$key${foo:0:1}$(tr '[:upper:]' '[:lower:]' <<< ${foo:1})"
    fi
  done
  echo "a1.sinks.k1.$key = ${!r}" >> $conf_file
done

for r in $channels_env; do
  substring=${r:15}
  key=$(echo $substring | tr '[:upper:]' '[:lower:]' | cut -d'_' -f 1)
  numbers=$(grep -o "_" <<< "$r" | wc -l)
  for (( i = 2; i < $numbers; i++ )); do
    foo=$(echo $substring | cut -d'_' -f $i)
    len=${#foo}
    if [ $len -eq 0 ]; then
      ((i=i+1))
      foo=$(echo $substring | cut -d'_' -f $i)
      key="$key.$(tr '[:upper:]' '[:lower:]' <<< $foo)"
    else
      key="$key${foo:0:1}$(tr '[:upper:]' '[:lower:]' <<< ${foo:1})"
    fi
  done
  echo "a1.channels.c1.$key = ${!r}" >> $conf_file
done

cat >> $conf_file <<- EOM
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
EOM

if [ ! -f /opt/flume/conf/.auto ]; then
  conf_file=$FLUME_CONF_FILE
fi

cat << EOF
Flume will run by using following config.
===============================================================================
$(cat $conf_file)
===============================================================================
EOF

/opt/flume/bin/flume-ng agent --conf conf --conf-file $conf_file --name a1 -Dflume.root.logger=INFO,console
