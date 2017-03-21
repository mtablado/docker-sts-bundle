FROM ubuntu:16.04
MAINTAINER Miguel Tablado

#RUN java -version \
#	&& echo PATH=$PATH \
#	&& echo JAVA_HOME=$JAVA_HOME

ARG user="mtablado"
ARG password="tete"
# User id
ARG uid
# Group ID
ARG gid
# TODO modify the group settings.
ARG group="develop"

# Log the parameters
RUN echo "user="${user} "uid="${uid}" "group="${group} gid="${gid} 

# Add the developer user
RUN groupadd -g ${gid} ${group} \
	&& useradd -m -u ${uid} -d /home/${user} -s /bin/sh ${user} -g ${group} \
    && echo "${user}:${password}" | chpasswd

# Debug. Show user id information.
RUN id ${user}

# This will install add-apt-repository dependency.
RUN apt-get update && apt-get install -y software-properties-common python-software-properties maven wget libcanberra-gtk-module git ssh

#ARG JDK_REPO="ppa:webupd8team/java"
#ARG JDK_VERSION="oracle-java8-installer"

# OpenJDK 8 as default
ARG JDK_REPO="ppa:openjdk-r/ppa"
ARG JDK_VERSION="openjdk-8-jdk"

RUN add-apt-repository ${JDK_REPO} \
	&& apt-get update \
	&& apt-get -y install ${JDK_VERSION} \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /var/cache/apt/*.bin

# Set JAVA_HOME environment variable to already installed openjdk-8-jdk.
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Update alternatives to use java 8.
RUN update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1 && \
	update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
	update-alternatives --set java "${JAVA_HOME}/bin/java" && \
	update-alternatives --set javac "${JAVA_HOME}/bin/javac"
	
# Debug instructions.
RUN java -version \
	&& javac -version \
	&& echo PATH=$PATH \
	&& echo JAVA_HOME=$JAVA_HOME
RUN ls -lia /usr/lib/jvm/ 
RUN which java && ls -lia /usr/bin/java && ls -lia /etc/alternatives/java && ls -lia /usr/lib/jvm/ 
RUN which javac && ls -lia /usr/bin/javac && ls -lia /etc/alternatives/java && ls -lia /usr/lib/jvm/ 

	
RUN java -version \
	&& javac -version \
	&& echo PATH=$PATH \
	&& echo JAVA_HOME=$JAVA_HOME

# Debug instructions.
RUN which java && ls -lia /usr/bin/java && ls -lia /etc/alternatives/java && ls -lia /usr/lib/jvm/ && ls /
RUN which javac && ls -lia /usr/bin/javac && ls -lia /etc/alternatives/java && ls -lia /usr/lib/jvm/ && ls /

RUN mkdir -p /home/${user}/.m2/ && chown -R ${user}:${group} /home/${user}/

# Save dependencies instead of download them at every mvn process.
VOLUME ["/home/${user}/.m2"]


ARG STS_DOWNLOAD_URL="http://download.springsource.com/release/STS/3.8.2.RELEASE/dist/e4.6/spring-tool-suite-3.8.2.RELEASE-e4.6.1-linux-gtk-x86_64.tar.gz"
ARG STS_INSTALLATION_DIR="/opt"

ARG TEMP_TAR_FILE_NAME="spring-tool-suite.tar.gz"

#RUN mkdir -p ${STS_INSTALLATION_DIR}

RUN echo ${STS_DOWNLOAD_URL}

WORKDIR ${STS_INSTALLATION_DIR}
RUN wget -qO ${TEMP_TAR_FILE_NAME} ${STS_DOWNLOAD_URL}
RUN tar -xzvf ${TEMP_TAR_FILE_NAME}

RUN chown -R root:${group} ${STS_INSTALLATION_DIR}/sts-bundle
RUN chmod -R 775 ${STS_INSTALLATION_DIR}/sts-bundle

# Add lombok (latest stable) project to eclipse sts.
ADD https://projectlombok.org/downloads/lombok.jar /tmp/lombok.jar
RUN java -jar /tmp/lombok.jar install ${STS_INSTALLATION_DIR}/sts-bundle/sts-3.8.2.RELEASE/ && \
    rm /tmp/lombok.jar

# Check permissions and lombok project.
RUN ls -lia ${STS_INSTALLATION_DIR}/sts-bundle/sts-3.8.2.RELEASE/

RUN mkdir -p /opt/alrajhi/omnichannel/logs/ && chmod -R 775 /opt/alrajhi
VOLUME /opt/alrajhi/omnichannel/logs/

# This ssh files will be moved to user home at start.sh script.
RUN mkdir -p /tmp/.ssh/
COPY "./ssh/config-server" /tmp/.ssh/id_rsa
COPY "./ssh/config-server.pub" /tmp/.ssh/id_rsa.pub
RUN chown -R ${user}:${user} /tmp/.ssh/

# Set user limit for open files.
COPY ["limits.conf","/etc/security/"]

ADD ./start.sh /start.sh
RUN chmod 755 /start.sh
USER ${user}

# TODO Send user with ${user}
CMD /start.sh mtablado
