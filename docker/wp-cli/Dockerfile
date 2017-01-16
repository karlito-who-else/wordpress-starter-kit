#
# Installs WordPress with wp-cli (wp.cli.org) installed
# Docker Hub: https://registry.hub.docker.com/u/conetix/wordpress-with-wp-cli/
# Github Repo: https://github.com/conetix/docker-wordpress-wp-cli

FROM php:5.6-apache

# CMD ["bash"]

ENV WP_CLI_VERSION 1.0.0

# Add wp-cli less dep
RUN apt-get update \
    && apt-get install -y less mysql-client libz-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && docker-php-ext-install zip

# Install wp-cli
RUN curl -OL https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar \
    && chmod +x wp-cli-${WP_CLI_VERSION}.phar \
    && mv wp-cli-${WP_CLI_VERSION}.phar /usr/local/bin/wp

# Enable tab completion and prepare www-data home directory
RUN curl -o /wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/v${WP_CLI_VERSION}/utils/wp-completion.bash \
    && mkdir -p /var/www \
    && echo 'source /wp-completion.bash' > /var/www/.bashrc \
    && chown www-data:www-data -R /var/www

# RUN echo 'date.timezone=utc' > /usr/local/etc/php/php.ini

COPY wp-cli.yml /var/www/wp-cli.yml

COPY docker/wp-cli/docker-entrypoint.sh /var/www/

# RUN touch /var/www/admin_password.txt

RUN chown www-data:www-data -R /var/www \
    && chmod +x /var/www/docker-entrypoint.sh

# Switch user to www-data (wp-cli doesn't allow being executed as root)
USER www-data

WORKDIR /var/www

HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
      CMD curl -f http://localhost:80/ || exit 1

ENTRYPOINT ["/var/www/docker-entrypoint.sh"]

CMD ["wp", "--debug", "--info"]
