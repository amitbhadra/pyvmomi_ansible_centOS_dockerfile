FROM centos:centos7

WORKDIR /mothership
COPY ./ /mothership
#USER root

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
#CMD ["/usr/sbin/init"]


# ------------------------------------------------------------------------------
# - Import the RPM GPG keys for repositories
# - Base install of required packages
# ------------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& rpm --import \
		http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7 \
	&& rpm --import \
		https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
	&& rpm --import \
		https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY \
	&& yum -y install \
			--setopt=tsflags=nodocs \
			--disableplugin=fastestmirror \
		centos-release-scl \
		centos-release-scl-rh \
		epel-release \
		https://centos7.iuscommunity.org/ius-release.rpm \
	&& yum -y install \
			--setopt=tsflags=nodocs \
			--disableplugin=fastestmirror \
		inotify-tools-3.14-8.el7 \
		openssh-clients-7.4p1-21.el7 \
		openssh-server-7.4p1-21.el7 \
		openssl-1.0.2k-19.el7 \
		python-setuptools-0.9.8-7.el7 \
		sudo-1.8.23-4.el7 \
		yum-plugin-versionlock-1.1.31-52.el7 \
	&& yum clean all \
	&& rm -rf /etc/ld.so.cache \
	&& rm -rf /sbin/sln \
	&& rm -rf /usr/{{lib,share}/locale,share/{man,doc,info,cracklib,i18n},{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} \
	&& rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/* \
	&& > /etc/sysconfig/i18n

EXPOSE 22

# Install requirements.
RUN yum -y install  epel-release initscripts unzip sshpass python-dns curl openssh-server openssh-clients\
 && yum -y update \
 && yum -y install \
      sudo \
      which \
 && yum clean all

#RUN systemctl start sshd

RUN curl https://bootstrap.pypa.io/2.7/get-pip.py --output get-pip.py
RUN python get-pip.py

# Install Ansible and other libs via Pip.
RUN pip install -r requirements.txt

ENTRYPOINT ["/bin/bash"]