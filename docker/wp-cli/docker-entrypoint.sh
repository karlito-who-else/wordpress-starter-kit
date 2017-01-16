#!/bin/bash

# Automatic exit from bash shell script on error
# set -e

# Set cwd
cd "${0%/*}"

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

if [ "${1:0:1}" = '-' ]; then
	echo "Running the 1:0:1 thing"
	set -- wp "$@"
fi

# if [ "$1" = 'wp' ]; then
	# if [ ! -z "$THEME_NAME" ]; then
	# 	su-exec wp theme install $THEME_NAME
	# fi
	# echo

	WP_EVALUATED_VERSION=`wp core version`

	echo "Wordpress version $WP_EVALUATED_VERSION detected"

	# echo wp --debug core verify-checksums #requires network access

	# echo 'Show installation information'
	# exec wp --debug --info

	# echo 'Show help information'
	# exec wp --debug help

	# echo 'Running plugin search test'
	# exec wp plugin search Digg

	# exec ls -lai ./html

	if [[ ! -z "$SITE_TITLE" || ! -z "$SITE_URL" || ! -z "$ADMIN_USER_LOGIN" || ! -z "$ADMIN_USER_EMAIL" || ! -z "$ADMIN_USER_DISPLAY_NAME" || ! -z "$ADMIN_USER_FIRST_NAME" || ! -z "$ADMIN_USER_LAST_NAME" ]]; then
		# echo 'Backing up wp-config.php file'
		# exec mv ./html/wp-config.php ./html/wp-config.php.bak

		# echo 'Generating wp-config.php file'
		# exec wp --debug core config
		#exec wp core config --dbname=testing --dbuser=wp --dbpass=securepswd --extra-php define( 'WP_DEBUG', true ); define( 'WP_DEBUG_LOG', true );

		if wp core is-installed; then
			echo 'Wordpress is already installed'
		else
			echo 'Running core install'
			# exec wp --debug core install --url=$SITE_URL --title=$SITE_TITLE --admin_user=$ADMIN_USER_LOGIN --admin_email=$ADMIN_USER_EMAIL --prompt=admin_password < admin_password.txt
			exec wp --debug core install --url="$SITE_URL" --title="$SITE_TITLE" --admin_user="$ADMIN_USER_LOGIN" --admin_email="$ADMIN_USER_EMAIL" --admin_password="$ADMIN_USER_PASSWORD"

			if [[ ! -z "$EDITOR_USER_LOGIN" || ! -z "$EDITOR_USER_EMAIL" || ! -z "$EDITOR_USER_DISPLAY_NAME" || ! -z "$EDITOR_USER_FIRST_NAME" || ! -z "$EDITOR_USER_LAST_NAME" ]]; then
				echo "Creating user '$EDITOR_USER_LOGIN'"
				exec wp --debug user create $EDITOR_USER_LOGIN $EDITOR_USER_EMAIL --role=admin --display_name=$EDITOR_USER_DISPLAY_NAME --first_name=$EDITOR_USER_FIRST_NAME --last_name=$EDITOR_USER_LAST_NAME
			fi

			if [[ ! -z "$THEME_SLUG" || ! -z "$THEME_NAME" || ! -z "$THEME_AUTHOR_NAME" || ! -z "$THEME_AUTHOR_URI" ]]; then
				echo "Scaffolding theme '$THEME_SLUG'"
				exec wp --debug scaffold _s $THEME_SLUG --theme_name="$THEME_NAME" --author="$THEME_AUTHOR_NAME" --author_uri="$THEME_AUTHOR_URI" --sassify --activate
			fi

			# if [ ! -z "$THEME_SLUG" ]; then
			# 	echo "Activating theme '$THEME_SLUG'"
			# 	exec wp --debug theme activate $THEME_SLUG
			# fi
			# echo

			echo "Installing plugin 'Jetpack'"
			exec wp --debug plugin install jetpack --activate-network
		fi
	fi

	echo 'WP-CLI init process complete; ready for start up.'

	exec wp --debug "$@"
# else
# 	echo '$1 != wp'
# fi

# echo "0: $0"
# echo "1: $1"
# echo "2: $2"

exec "$@"
