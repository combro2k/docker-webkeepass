FROM combro2k/perlbrew:latest

MAINTAINER Martijn van Maurik <docker@vmaurik.nl>

# Environment variables
ENV HOME=/root \
    INSTALL_LOG=/var/log/build.log

# Add first the scripts to the container
ADD resources/bin/ /usr/local/bin/

# Run the installer script
RUN /bin/bash -l -c 'bash /usr/local/bin/setup.sh build'

ADD resources/srv/ /srv/
ADD resources/data/ /data/

# Run the last bits and clean up
RUN /bin/bash -l -c 'bash /usr/local/bin/setup.sh post_install | tee -a ${INSTALL_LOG} > /dev/null 2>&1 || exit 1'

VOLUME /data

CMD ["/usr/local/bin/run"]
