## Introduction
This nginx image is based on the ```alpine:latest```'s' build from [docker hub](https://hub.docker.com/_/nginx/).

## How to use this image
Basic usage can be found on their official [docker hub](https://hub.docker.com/_/nginx/) repository.

#### Port
The image exposes ```port 80``` and ```443``` for outside access.

#### Environment variables
The ```docker-entrypoint.sh``` can accept *2 environment variables*:

1. ```PHP_SITE``` - The configuration file that will be used which can be found in ```sites/``` directory. Currently it supports **symfony** and **laravel** site configurations (default: ```default.conf``` from original nginx installation).
2. ```PHP_SOCKET``` - Default value is ```php:9000```. If the *php image* uses a different *name* and *port* then provide this environment variable the correct values, eg: ```php-with-xdebug:9001```.


#### Docker Compose
Sample docker compose configuration:

```yaml
version: '3'
services:
    nginx:
        image: ksungcaya/docker-nginx:latest
        depends_on:
            - php-xdebug # some php image
        environment:
            PHP_SITE: symfony
            PHP_SOCKET: php-xdebug:9000 # same with custom php image name with its port
        volumes:
            - .:/var/www/html
        ports:
            - "8888:80"
        networks:
            - appnet
```

## Tagging
```shell
docker build -t $vendor/docker-nginx .
```