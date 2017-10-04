FROM ubuntu:16.04

MAINTAINER Andrew Sherepenko <andrew.sherepenko@gmail.com>

# Version
ENV ANDROID_TOOLS_VERSION 3859397

# Build environment
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV ANDROID_HOME /opt/android-sdk

# PATH
ENV PATH $JAVA_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# Noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Working directory
WORKDIR /tmp

# Update apt-get
RUN apt-get update && \
    apt-get dist-upgrade -y

# Install packages
RUN dpkg --add-architecture i386 && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        lib32ncurses5 \
        lib32stdc++6 \
        lib32z1-dev \
        libc6-dev \
        pkg-config \
        software-properties-common \
        unzip \
        wget \
        zip

# Install Oracle JDK
RUN apt-add-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get -y install openjdk-8-jdk

# Install Android SDK
RUN wget -q -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_TOOLS_VERSION}.zip --no-check-certificate && \
    mkdir -p $ANDROID_HOME && \
    unzip -q sdk-tools.zip && \
    mv tools $ANDROID_HOME && \
    rm -f sdk-tools.zip

# Install Android Tools and Repos
RUN echo "Update Android SDK" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --update && \
    echo "Install android-26" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-26" && \
    echo "Install build-tools-26.0.2" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "build-tools;26.0.2" && \
    echo "Install android-m2repository" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;android;m2repository" && \
    echo "Install google-m2repository" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;google;m2repository" && \
    echo "Install google_play_services" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager "extras;google;google_play_services" && \
    echo "Terms and Conditions" && \
    echo y | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp* /tmp/*

# Confirm Terms and Conditions of the Android SDK
RUN mkdir -p "${ANDROID_HOME}/licenses" && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_HOME}/licenses/android-sdk-license"
