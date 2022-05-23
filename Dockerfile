# DOCKER_BUILDKIT=1 docker build . --secret id=ua-attach-config,src=ua-attach-config.yaml -t nginx-fips:1.18

FROM public.ecr.aws/lts/nginx:1.18-20.04_beta

RUN --mount=type=secret,id=ua-attach-config \
   apt-get update \
    # install the UA client
    && apt-get install --no-install-recommends -y ubuntu-advantage-tools ca-certificates \
    # attach a UA subscription
    && ua attach --attach-config /run/secrets/ua-attach-config \
    # upgrade packages eligible for FIPS/ESM updates
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y openssl \
    # don’t forget to clean the layer!
    && apt-get purge --auto-remove -y ubuntu-advantage-tools ca-certificates && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -newkey rsa:2048 -nodes -keyout /etc/nginx/ssl/test.key -x509 -days 365 -out /etc/nginx/ssl/test.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=example.com"

ADD ./nginx.conf /etc/nginx/nginx.conf

# > docker run --rm --name nginx-fips nginx-fips:1.18
# > docker exec -it nginx-fips bash
### MD5 is disabled in FIPS mode, and the following command will fail
# root@9aa1de924c3f:/# (echo "GET /" ; sleep 1) | openssl s_client -connect 127.0.0.1:443 -cipher RC4-MD5
### AES256-SHA is a permitted cipher in FIPS mode, it works!
# root@9aa1de924c3f:/# (echo "GET /" ; sleep 1) | openssl s_client -connect 127.0.0.1:443 -cipher AES256-SHA
