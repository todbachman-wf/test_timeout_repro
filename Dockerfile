FROM google/dart:2.4 as dart2

# Install Chromium and wget.
RUN apt-get update -qq
RUN apt-get update && apt-get install -y \
    chromium \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install the stable version of chrome.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get -qq update && apt-get install -y google-chrome-stable

WORKDIR /build/

COPY pubspec.yaml /build/
RUN pub get

COPY . /build/
RUN pub run build_runner build test -o build

# Run the tests on Chromium.
ENV CHROMIUM_FLAGS='--no-sandbox'
RUN mv /usr/bin/chromium /usr/bin/google-chrome && \
    google-chrome --version
RUN pub run test --precompiled build -p chrome -r expanded test/big_test.dart

# Specify the location of the Chrome debugging log.
ENV CHROME_LOG_FILE=/build/chrome.log

# Run the tests on Chrome proper.
RUN mv /usr/bin/google-chrome-stable /usr/bin/google-chrome && \
    sed -i --follow-symlinks -e 's/\"\$HERE\/chrome\"/\"\$HERE\/chrome\" --no-sandbox/g' /usr/bin/google-chrome && \
    google-chrome --version
RUN pub run test --precompiled build -p chrome -r expanded test/big_test.dart
