FROM		centos:latest
MAINTAINER 	JAkub Scholz "www@scholzj.com"

RUN yum -y update && yum clean all \
        && yum -y --setopt=tsflag=nodocs install java-1.8.0-openjdk-headless \
        && yum clean all \
        && adduser -m qpidd-gui 
COPY ./qpid-qmf2-tools /home/qpidd-gui/qpid-qmf2-tools
RUN chown -R qpidd-gui /home/qpidd-gui/qpid-qmf2-tools
ENV QMF_GUI_VERSION 0.32
WORKDIR /home/qpidd-gui/qpid-qmf2-tools/bin

# Add entrypoint
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

USER qpidd-gui

# Expose port and run
EXPOSE 8080
CMD ["./QpidRestAPI.sh"]
