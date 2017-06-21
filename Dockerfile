FROM ubuntu:16.04

MAINTAINER Andrew Sherepenko

ENV ANDROID_SDK_VERSION="26.0.0"

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV ANDROID_HOME /opt/android-sdk-linux

# Config PATH
ENV PATH $JAVA_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# Setup Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Default locale
ENV LANG en_US.UTF-8

# Working directory
WORKDIR /opt

# Update apt-get
RUN apt-get update && \
    apt-get dist-upgrade -y

# Install packages
RUN apt-get install -y --no-install-recommends \
        autoconf \
        build-essential \
        bzip2 \
        curl \
        gcc \
        git \
        groff \
        lib32stdc++6 \
        lib32z1 \
        lib32z1-dev \
        lib32ncurses5 \
        libc6-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libxslt-dev \
        libxml2-dev \
        locales \
        m4 \
        make \
        ncurses-dev \
        ocaml \
        openssh-client \
        pkg-config \
        python-software-properties \
        rsync \
        software-properties-common \
        unzip \
        wget \
        zip \
        zlib1g-dev

# Set locale
RUN locale-gen $LANG

# Install Oracle JDK
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get -y install oracle-java8-installer

# Install Android SDK
RUN wget -q -O android-sdk-linux.tgz https://dl.google.com/android/android-sdk_${ANDROID_SDK_VERSION}-linux.tgz && \
    tar -xvzf android-sdk-linux.tgz && \
    rm -f android-sdk-linux.tgz

# Install Android Tools and Repos
RUN echo "Install platform-tools" && \
    echo y | ./android --silent update sdk --no-ui --all --filter platform-tools && \
    echo "Install android-26" && \
    echo y | ./android --silent update sdk --no-ui --all --filter android-26 && \
    echo "Install build-tools-26.0.0" && \
    echo y | ./android --silent update sdk --no-ui --all --filter build-tools-26.0.0 && \
    echo "Install extra-android-m2repository" && \
    echo y | ./android --silent update sdk --no-ui --all --filter extra-android-m2repository && \
    echo "Install extra-google-m2repository" && \
    echo y | ./android --silent update sdk --no-ui --all --filter extra-google-m2repository && \
    echo "Install extra-android-support" && \
    echo y | ./android --silent update sdk --no-ui --all --filter extra-android-support && \
    echo "Install android-support-repository" && \
    echo y | ./android --silent update sdk --no-ui --all --filter android-support-repository && \
    echo "Install android-support-library" && \
    echo y | ./android --silent update sdk --no-ui --all --filter android-support-library && \
    echo "Install extra-google-google_play_services" && \
    echo y | ./android --silent update sdk --no-ui --all --filter extra-google-google_play_services && \
    echo "Install google-play-services" && \
    echo y | ./android --silent update sdk --no-ui --all --filter google-play-services && \
    echo "Install google-repository" && \
    echo y | ./android --silent update sdk --no-ui --all --filter google-repository

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Confirm Terms and Conditions of the Android SDK
RUN mkdir "${ANDROID_HOME}/licenses" || true && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"
