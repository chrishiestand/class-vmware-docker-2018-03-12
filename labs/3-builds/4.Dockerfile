FROM alpine

RUN curl -s -o docker.sh https://get.docker.com
RUN chmod +x docker.sh
RUN ./docker.sh
RUN rm docker.sh
