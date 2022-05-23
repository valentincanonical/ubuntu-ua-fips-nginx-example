# Create a FIPS-enabled NGINX with Ubuntu 20.04

> **Warning**    
> You **must be** using an Ubuntu Pro or UA-enabled host in FIPS mode.    
> Let's get started quickly with an Ubuntu Pro FIPS [EC2 instance on AWS](https://ubuntu.com/aws/fips).

```sh
cp ua-attach-config.yaml.template ua-attach-config.yaml
```

Retrieve a UA token from [ubuntu.com/advantage](https://ubuntu.com/advantage) (free for personal use).

Edit the `ua-attach-config.yaml` file to add the obtained token to the `token` field.

Build the FIPS-enabled Ubuntu-based NGINX container image:

```sh
DOCKER_BUILDKIT=1 docker build . --secret id=ua-attach-config,src=ua-attach-config.yaml -t nginx-fips:1.18
```

We can now test it works as expected:

```sh
> docker run -d --name nginx-fips nginx-fips:1.18
> docker exec -it nginx-fips dpkg-query --show openssl
> docker exec -it nginx-fips bash
# MD5 is disabled in FIPS mode, and the following command will fail
root@9aa1de924c3f:/# (echo "GET /" ; sleep 1) | openssl s_client -connect 127.0.0.1:443 -cipher RC4-MD5
# AES256-SHA is a permitted cipher in FIPS mode, it works!
root@9aa1de924c3f:/# (echo "GET /" ; sleep 1) | openssl s_client -connect 127.0.0.1:443 -cipher AES256-SHA
```

The end!

---

> Inspired by https://github.com/canonical/ubuntu-advantage-client/blob/main/docs/tutorials/create_a_fips_docker_image.md
