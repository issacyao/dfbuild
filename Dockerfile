# 
# MAINTAINER        issacyao <issacyao888@gmail.com> 
# DOCKER-VERSION    1.11.1 
# 
# Dockerizing debian:8.4: Dockerfile for building debian images 
# 
FROM debian:8.4
MAINTAINER issacyao <issacyao888@gmail.com> 

ENV TZ "Asia/Shanghai" 
# ENV TERM xterm 


RUN touch /run.sh && \
	echo '#!/bin/bash' > /run.sh && \
	chmod +x /run.sh


RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://ftp.us.debian.org/debian jessie main non-free contrib" >/etc/apt/sources.list && \
    echo "deb http://ftp.us.debian.org/debian jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99syntapic
RUN echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99syntapic

RUN apt-get -o Acquire::Check-Valid-Until=false update -y


#RUN DEBIAN_FRONTEND=noninteractive apt-get install vim less net-tools apt-utils -y
RUN echo "syntax on" > /root/.vimrc


RUN DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKRH4XGENbiOH+LQUddNhGDW5J0qsKNuZYrckyg689mP6q7CxiOJP26jRoPJzaQvlEVkcvCubz6yURVihS+2Xa+KTQcSe/dltREgrcPPxFIrUNDFGCptvD+eSbHn3ULOZ0w2NL8V2F13GLV6ccITF+8IYp1QWT74aFslTVWw2sDv2wx7RSiAhFeNvqb1LVh31Efb+ySHmYNl8ULZ6sDtTqkj8HjLW2VzOS1RVEzgZdaRmgsUWeB0qtvLgDVSovoRZyOQJORzZu5AcV/8+EEcWIus60H7GIM7GC2lfy6dbzAnu49gc+eYNGGjTSanDpAhnPY2shI+xTzyvPSmZQ8F0n issacyao@github.com" > /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys
RUN sed -i 's/Port 22/Port 80/' /etc/ssh/sshd_config
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# ENV NOTVISIBLE "in users profile"
# RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "/etc/init.d/ssh start > /dev/null &" >> /run.sh


RUN echo "echo service-start" >> /run.sh


#RUN apt-get clean -y
#RUN apt-get autoclean -y
#RUN apt-get autoremove -y

EXPOSE 80

#CMD ["/run.sh"]
ENTRYPOINT /run.sh && /bin/bash
