ARG __src_image=registry.access.redhat.com/ubi8/ubi-minimal:latest
FROM ${__src_image}

LABEL maintainer="Myhael76"

# Define arguments and set the default values 
ARG __install_dir=/mnt/aris
ARG __aris_user=aris10
ARG __aris_user_id=1003
ARG __aris_group=aris10
ARG __aris_group_id=1003

# Define ARIS environment variables
ENV TARGETDIR="${__install_dir}" \
    user="${__aris_user}"

# Hopefully this layer is cacheable
RUN microdnf -y update &&\ 
    microdnf -y install \
        dejavu-sans-fonts \
        fontconfig \
        logrotate \
        gettext \
        gzip \
        java-11-openjdk-devel \
        less \
        nc \
        net-tools \
        passwd \
        procps \
        psmisc \
        shadow-utils \
        tar \
        which \
        &&\ 
    microdnf clean all &&\ 
    rm -rf /var/cache/yum &&\
    groupadd -g ${__aris_group_id} ${__aris_group} &&\
    useradd -u ${__aris_user_id} -m -g ${__aris_group} ${__aris_user} &&\ 
    mkdir -p "{TARGETDIR}" &&\
    chown ${__aris_user_id}:${__aris_group_id} "{TARGETDIR}"
