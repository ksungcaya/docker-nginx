#!/bin/bash

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}

if [ "$1" = 'nginx' ]; then
    file_env 'PHP_SITE'
    file_env 'PHP_SOCKET'

    # Enable available site configurations
    echo
    for f in /etc/nginx/sites-available/*; do
        filename=$(basename $f)

        if [ "$filename" != '*' ]; then
            echo "enabling $f site configuration..."

            ln -sf "/etc/nginx/sites-available/$filename" "/etc/nginx/conf.d/$filename"
            echo
        fi
    done
    echo

    # Enable custom site from uploaded configurations
    if [ "$PHP_SITE" ]; then
        echo
        echo "enabling custom '$PHP_SITE' site configuration..."

        ln -sf "/etc/nginx/sites-custom/$PHP_SITE" "/etc/nginx/conf.d/$PHP_SITE"
        echo
    fi

    if [ "$PHP_SOCKET" ]; then
        echo "changing fastcgi_pass entry with host: $PHP_SOCKET"

        for f in /etc/nginx/conf.d/*; do
            filename=$(basename $f)
            if [ "$filename" != '*' ]; then
                sed -i "s/fastcgi_pass php:9000/fastcgi_pass $PHP_SOCKET/g" "/etc/nginx/conf.d/$filename"
	   		fi
        done
        echo
    fi
fi

exec "$@"
