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
    echo "deb http://mirrors.163.com/debian/ jessie main non-free contrib" >/etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list
#    echo "deb-src http://mirrors.163.com/debian/ jessie main non-free contrib" >>/etc/apt/sources.list && \
#    echo "deb-src http://mirrors.163.com/debian/ jessie-proposed-updates main non-free contrib" >>/etc/apt/sources.list

RUN echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/99syntapic
RUN echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99syntapic

RUN apt-get -o Acquire::Check-Valid-Until=false update -y


RUN DEBIAN_FRONTEND=noninteractive apt-get install vim less net-tools apt-utils -y
RUN echo "syntax on" > /root/.vimrc


RUN DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKRH4XGENbiOH+LQUddNhGDW5J0qsKNuZYrckyg689mP6q7CxiOJP26jRoPJzaQvlEVkcvCubz6yURVihS+2Xa+KTQcSe/dltREgrcPPxFIrUNDFGCptvD+eSbHn3ULOZ0w2NL8V2F13GLV6ccITF+8IYp1QWT74aFslTVWw2sDv2wx7RSiAhFeNvqb1LVh31Efb+ySHmYNl8ULZ6sDtTqkj8HjLW2VzOS1RVEzgZdaRmgsUWeB0qtvLgDVSovoRZyOQJORzZu5AcV/8+EEcWIus60H7GIM7GC2lfy6dbzAnu49gc+eYNGGjTSanDpAhnPY2shI+xTzyvPSmZQ8F0n issacyao@github.com" > /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# ENV NOTVISIBLE "in users profile"
# RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "/etc/init.d/ssh start &&" >> /run.sh

EXPOSE 22


RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
	unzip \
	wget \
	curl \
	nginx \
	openssl \
	libmcrypt-dev \
	mcrypt \
	php5-fpm \
	php5-cli \
	php5-curl \
	php5-mcrypt \
	php5-gd \
	php5-json \
	php5-readline \
	php5-xcache \
	php-pear

RUN rm -rf /usr/share/nginx/html 

RUN mkdir /www

RUN wget -O /tmp/gitblog-test.zip http://sz.ctfs.ftn.qq.com/ftn_handler/0eae00c0ad6b1ef956d93b539fbe7e968c08c8ea53957139a44cf82577651e59241e6112a9dadd461d24670505b27586ad2803d6f65084569e3de321916658bc/\?fname\=gitblog-test.zip\&k\=23346537f665f8c8e3a08a164064001805560706005c56544b040703004906070755485651000b1a02075d525e06510357555002667432500f40075b09031f43034711191c0d42375b\&fr\=00\&\&txf_fid\=ec69e9ff9f3345ddd98ae4b2c7bbfae116e27a2b\&xffz\=3538544
RUN unzip tmp/gitblog-test.zip -d /www


RUN mv /www/nginx_nginx.conf /etc/nginx/nginx.conf
RUN mv /www/nginx_default.conf /etc/nginx/sites-available/default

RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php5/cli/php.ini
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php5/fpm/php.ini

RUN copy /www/php_www.conf /etc/php5/fpm/pool.d/www.conf


RUN chown -R www-data:www-data /www/gitblog-master

RUN echo "/etc/init.d/nginx start &&" >> /run.sh
RUN echo "/etc/init.d/php5-fpm start &&" >> /run.sh

VOLUME ["/www/gitblog-master/blog"]

EXPOSE 8008


RUN DEBIAN_FRONTEND=noninteractive apt-get install haproxy -y
#ADD haproxy.cfg /etc/haproxy/haproxy.cfg
RUN copy /tmp/res/haproxy.cfg /etc/haproxy/haproxy.cfg
RUN echo "/etc/init.d/haproxy start &&" >> /run.sh

EXPOSE 80

RUN DEBIAN_FRONTEND=noninteractive apt-get install n2n -y

# RUN echo "supernode -l 8888 > /dev/null &" >> /run.sh
# EXPOSE 8888

RUN apt-get clean -y
RUN apt-get autoclean -y
RUN apt-get autoremove -y


RUN echo "echo service-start" >> /run.sh

CMD ["/run.sh"]
