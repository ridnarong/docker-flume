FROM java
MAINTAINER Ridnarong Promya
RUN curl http://apache.stu.edu.tw/flume/1.6.0/apache-flume-1.6.0-bin.tar.gz | tar -xzC /opt/
RUN mv /opt/apache-flume-1.6.0-bin /opt/flume
ADD run.sh /opt/flume/run.sh
RUN chmod +x /opt/flume/run.sh
ENV FLUME_SOURCES_TYPE netcat
ENV FLUME_SOURCES_BIND 0.0.0.0
ENV FLUME_SOURCES_PORT 44444
ENV FLUME_SINKS_TYPE logger
ENV FLUME_CHANNELS_TYPE memory
ENV FLUME_CHANNELS_CAPACITY 100
ENV FLUME_CHANNELS_TRANSACTION_CAPACITY 100
WORKDIR /opt/flume
CMD ["./run.sh"]
