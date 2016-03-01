# Apache flume's Dockerfile

Introduction
============
Flume is a distributed, reliable, and available service for efficiently collecting, aggregating, and moving large amounts of log data. It has a simple and flexible architecture based on streaming data flows. It is robust and fault tolerant with tunable reliability mechanisms and many failover and recovery mechanisms. It uses a simple extensible data model that allows for online analytic application.

This docker image contains Apache flume which can generate configuration file base on environment variables. This make running flume more easier and fun. You can jumpstart from simple default TCP source at port 44444, memory channel, and Logger to stdout as sink. Furthermore you can mount plugin.d folder or conf folder for more custom config.

This docker image came with following default ENV:

```sh
FLUME_SOURCES_TYPE netcat
FLUME_SOURCES_BIND 0.0.0.0
FLUME_SOURCES_PORT 44444
FLUME_SINKS_TYPE logger
FLUME_CHANNELS_TYPE memory
FLUME_CHANNELS_CAPACITY 100
FLUME_CHANNELS_TRANSACTION_CAPACITY 100
```

Configuration
=============
Flume's configuration will be generated from environment variables with `FLUME_` prefix. Currently we only support single source, sink, and channel which can generate from `FLUME_SOURCES_`, `FLUME_SINKS_`, `FLUME_CHANNELS_` prefix respectively. If the suffix are multiple word with `_` separation it will try to create camel-case words for it. Double underscore `__` in environment variables' name will convert to dot `.`. Here are some examples:

* `FLUME_SOURCES_TYPE netcat` will be `a1.sources.r1.type = netcat`
* `FLUME_CHANNELS_TRANSACTION_CAPACITY 100` will be `a1.channels.c1.transactionCapacity = 100`
* `FLUME_SINKS_DESERIALIALIZER__MAX_LINE_LENGTH 2048` will be `a1.sinks.k1.deserialializer.maxLineLength = 2048`

Run
===
From above default configuration we open netcat source at port 44444 and print output as logger into stdout. We can run docker with `-p` to expose source port in the container.

`docker run -it --rm -p 44444:44444 ridnarong/flume`

after that you can test it with `telnet` or `nc` command:
```sh
$ telnet localhost 44444
Trying ::1...
Connected to localhost.
Escape character is '^]'.
test
OK
```

In container's shell will print out as following:

```sh
2016-02-29 03:37:37,970 (SinkRunner-PollingRunner-DefaultSinkProcessor) [INFO - org.apache.flume.sink.LoggerSink.process(LoggerSink.java:94)] Event: { headers:{} body: 74 65 73 74 0D                                  test. }

```

If you develop your own source or sink you may want to attach your plugin folder into container and passing your configuration. This can be done by following command:

`docker run -it --rm -e FLUME_SOURCES_TYPE=org.example.MySource  -v /home/me/flume-plugins.d:/opt/flume/plugins.d ridnarong/flume`
