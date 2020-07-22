# Create a non-root user zeppelin

```shell
# Make sure uid and gid are both 1000
# groupadd zeppelin -g 1000
# useradd -b /home/zeppelin -d /home/zeppelin -m -u 1000 zeppelin -g 1000
```

# Create build image

```Dockerfile
FROM maven:3.6-jdk-8

COPY build-zeppelin-entrypoint.sh  /entrypoint.sh

RUN groupadd zeppelin -g 1000 && \
    useradd -b /home/zeppelin -d /home/zeppelin -m -u 1000 zeppelin -g 1000 && \
    chmod +x /entrypoint.sh

USER zeppelin

WORKDIR /home/zeppelin/zeppelin

ENTRYPOINT [ "/entrypoint.sh"]

```

```shell
# docker build -t zeppelin-builder ./ -f build-zeppelin-Dockerfile
# usermod -aG docker zeppelin
```

# build zeppelin

```shell
# docker run -it --user zeppelin --rm -w /home/zeppelin -v zeppelin-source:/home/zeppelin zeppelin-builder
```

# build zeppelin image

```shell
# mv zeppelin-source/zeppelin/zeppelin-distribution/target/zeppelin-*.tar.gz zeppelin-source/zeppelin/scripts/docker/zeppelin/bin/
# cd zeppelin-source/zeppelin/scripts/docker/zeppelin/bin/
# docker build -t registry.vizion.ai/library/ml/zeppelin:SNAPSHOT-0.9.0-$(git rev-parse --short HEAD) .
# docker push registry.vizion.ai/library/ml/zeppelin:SNAPSHOT-0.9.0-$(git rev-parse --short HEAD)
```