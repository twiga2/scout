FROM nvidia/cuda:11.6.0-cudnn8-runtime-ubuntu20.04

# BEGIN SCOUTBOT SETUP

# Install apt packages
RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        libgl1 \
        libglib2.0-0 \
 && rm -rf /var/cache/apt \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install scoutbot==0.1.17
RUN pip3 uninstall -y onnxruntime
RUN pip3 install onnxruntime-gpu
RUN scoutbot fetch --config phase1
RUN scoutbot fetch --config mvp

# END SCOUTBOT SETUP

# BEGIN SCOUT SETUP

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install curl -y
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash
RUN apt-get install nodejs -y
RUN apt-get install wget -y
RUN apt-get install gnupg -y
RUN apt-get install mongodb -y
RUN apt-get install graphicsmagick -y
RUN apt-get install dcraw -y

WORKDIR /usr/src/app

COPY package*.json ./
COPY . .

RUN mkdir /tmp/log

RUN npm cache clean --force
RUN rm -rf node_modules
RUN npm install
RUN npm install sails -g
RUN npm install mongo-express@1.0.0 -g
RUN npm install gm -g
RUN npm install readline-sync --save
RUN npm install connect-mongodb-session --save
RUN npm install sails --save


EXPOSE 1337

RUN ["chmod", "+x", "/usr/src/app/docker-entrypoint.sh"]
CMD ["/usr/src/app/docker-entrypoint.sh"]
