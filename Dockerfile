FROM ubuntu:16.04

MAINTAINER Andrew Sherepenko

# Current version
ENV ANDROID_TOOLS_VERSION="3859397"

# Build environment
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ANDROID_HOME /opt/android-sdk

# PATH
ENV PATH $JAVA_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# Locale
ENV LANG en_US.UTF-8

# Noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Working directory
WORKDIR /opt

# Update apt-get
RUN apt-get update && \
    apt-get dist-upgrade -y

# Install packages
RUN apt-get install -y --no-install-recommends \
        apt-utils \
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

# Setup locale
RUN locale-gen $LANG

# Install Oracle JDK
RUN apt-add-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get -y install openjdk-8-jdk

# Install Android SDK
RUN wget -q -O tools.zip https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_TOOLS_VERSION.zip --no-check-certificate && \
    unzip -q tools.zip && \
    mkdir -p $ANDROID_HOME && \
    mv tools $ANDROID_HOME/tools && \
    rm -f tools.zip

# Install Android Tools and Repos
RUN echo "Install platform-tools" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter platform-tools && \
    echo "Install android-26" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter android-26 && \
    echo "Install build-tools-26.0.0" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter build-tools-26.0.0 && \
    echo "Install extra-android-m2repository" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter extra-android-m2repository && \
    echo "Install extra-google-m2repository" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter extra-google-m2repository && \
    echo "Install extra-android-support" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter extra-android-support && \
    echo "Install android-support-repository" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter android-support-repository && \
    echo "Install android-support-library" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter android-support-library && \
    echo "Install extra-google-google_play_services" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter extra-google-google_play_services && \
    echo "Install google-repository" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter google-repository && \
    echo "Install google-play-services" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --silent update sdk --no-ui --all --filter google-play-services

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup Gradle
ENV TERM dumb
ENV JAVA_OPTS "-Xms4096m -Xmx4096m"
ENV GRADLE_OPTS "-XX:+UseG1GC -XX:MaxGCPauseMillis=1000"

# Confirm Terms and Conditions of the Android SDK
RUN mkdir "${ANDROID_HOME}/licenses" || true && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"
