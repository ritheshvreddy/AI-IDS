# CICFlowMeter 4.0 (github.com/ahlashkari/CICFlowMeter, Java + jnetpcap) for offline pcap -> flow CSV conversion.
# Used to turn capture-dos-goldeneye.pcap into capture-dos-goldeneye_Flow.csv.
#
# Build (from the project root):
#   docker build -t cicflowmeter -f testing/CICFlowMeter.Dockerfile testing
# Convert (the capture is pcapng, which CICFlowMeter cannot read, so editcap rewrites it as classic pcap first):
#   docker run --rm -v "%cd%/testing:/data" cicflowmeter sh -c "editcap -F pcap /data/capture-dos-goldeneye.pcap /tmp/capture-dos-goldeneye.pcap && cd /opt/dist/bin && JAVA_OPTS=-Djava.library.path=$LD_LIBRARY_PATH ./cfm /tmp/capture-dos-goldeneye.pcap /tmp/out/ && cp /tmp/out/capture-dos-goldeneye.pcap_Flow.csv /data/capture-dos-goldeneye_Flow.csv"
FROM eclipse-temurin:8-jdk
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      git maven libpcap-dev unzip curl wireshark-common && rm -rf /var/lib/apt/lists/*
# Gradle 4.2 is the version pinned by the project's wrapper; fetched with curl instead of the wrapper
RUN curl -fsSL -o /tmp/gradle.zip https://services.gradle.org/distributions/gradle-4.2-bin.zip \
 && unzip -q /tmp/gradle.zip -d /opt && rm /tmp/gradle.zip
WORKDIR /opt
RUN git clone --depth 1 https://github.com/ahlashkari/CICFlowMeter.git
WORKDIR /opt/CICFlowMeter
RUN mvn -q install:install-file -Dfile=jnetpcap/linux/jnetpcap-1.4.r1425/jnetpcap.jar \
      -DgroupId=org.jnetpcap -DartifactId=jnetpcap -Dversion=1.4.1 -Dpackaging=jar
RUN /opt/gradle-4.2/bin/gradle --no-daemon installDist && cp -r build/install/CICFlowMeter /opt/dist
ENV LD_LIBRARY_PATH=/opt/CICFlowMeter/jnetpcap/linux/jnetpcap-1.4.r1425
