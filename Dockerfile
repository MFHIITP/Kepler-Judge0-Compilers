FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install curl and ca-certificates early so we can use them right away
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install latest Go manually (high cache reuse)
ENV GO_VERSION=1.22.0
RUN curl -fSsL "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz" -o /tmp/go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt && \
    rm -rf /tmp/*

# Install the rest of the common dependencies
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \
    build-essential \
    wget \
    unzip \
    gnupg2 \
    git \
    locales \
    bison \
    re2c \
    libcap-dev \
    clang \
    gnustep-devel \
    sqlite3 \
    openjdk-11-jdk \
    python2 python2-dev \
    python3 python3-dev python3-pip \
    nodejs npm \
    php \
    bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    gcc-9 g++-9 \
    gcc-10 g++-10

# Register both with update-alternatives
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100
# Kotlin setup
ENV KOTLIN_VERSION=1.3.70
RUN curl -fSsL "https://github.com/JetBrains/kotlin/releases/download/v$KOTLIN_VERSION/kotlin-compiler-$KOTLIN_VERSION.zip" -o /tmp/kotlin.zip && \
    unzip -d /opt/kotlin /tmp/kotlin.zip && \
    ln -s /opt/kotlin/kotlinc/bin/kotlinc /usr/local/bin/kotlinc && \
    rm -rf /tmp/*

# TypeScript setup
ENV TYPESCRIPT_VERSION=3.7.4
RUN npm install -g typescript@$TYPESCRIPT_VERSION

RUN set -xe && \
    curl -fSsL "https://download.java.net/java/GA/jdk13.0.1/cec27d702aa74d5a8630c65ae61e4305/9/GPL/openjdk-13.0.1_linux-x64_bin.tar.gz" -o /tmp/openjdk13.tar.gz && \
    mkdir /usr/local/openjdk13 && \
    tar -xf /tmp/openjdk13.tar.gz -C /usr/local/openjdk13 --strip-components=1 && \
    rm /tmp/openjdk13.tar.gz && \
    ln -s /usr/local/openjdk13/bin/javac /usr/local/bin/javac && \
    ln -s /usr/local/openjdk13/bin/java /usr/local/bin/java && \
    ln -s /usr/local/openjdk13/bin/jar /usr/local/bin/jar

# .NET SDK setup
RUN curl -fSsL "https://download.visualstudio.microsoft.com/download/pr/7d4c708b-38db-48b2-8532-9fc8a3ab0e42/23229fd17482119822bd9261b3570d87/dotnet-sdk-3.1.202-linux-x64.tar.gz" -o /tmp/dotnet.tar.gz && \
    mkdir -p /usr/local/dotnet && \
    tar -xf /tmp/dotnet.tar.gz -C /usr/local/dotnet && \
    ln -s /usr/local/dotnet/dotnet /usr/bin/dotnet && \
    rm -rf /tmp/*

# RUN apt-get update && apt-get install -y --fix-missing mono-complete

RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs


# Optionally make Mono available globally
# ENV PATH="/usr/local/mono-6.6.0.161/bin:$PATH"

# Locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Install Isolate
RUN git clone https://github.com/judge0/isolate.git /tmp/isolate && \
    cd /tmp/isolate && \
    git checkout ad39cc4d0fbb577fb545910095c9da5ef8fc9a1a && \
    make -j$(nproc) install && \
    rm -rf /tmp/*
ENV BOX_ROOT=/var/local/lib/isolate

LABEL maintainer="Herman Zvonimir Došilović <hermanz.dosilovic@gmail.com>"
LABEL version="1.4.0"

CMD ["bash"]


# judge0-kepler-compilers
# 2.43 GB as of now with just these important compilers