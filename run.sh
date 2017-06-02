#!/bin/bash
DRUPAL_HOME=${DRUPAL_HOME:-/var/www}
MEDIABUCKET=${MEDIABUCKET:-jellyfish-agencysite-drupal}
GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-/etc/bucketaccess.json}
USERID=$(id -u www-data)
GRPID=$(id -g www-data)

[ -f "$GOOGLE_APPLICATION_CREDENTIALS" ] && /usr/bin/gcsfuse --uid $(id -u www-data) --gid $(id -g www-data) --dir-mode="777" --file-mode="777" -o allow_other -o nonempty $MEDIABUCKET $DRUPAL_HOME/sites/default/files
if [ $? -eq 0 ] ;
then 
	echo "$DRUPAL_HOME/sites/default/files mounted successfully with $MEDIABUCKET"
        $DRUPAL_HOME/bin/magento cache:clean

else 
   echo "$DRUPAL_HOME/sites/default/files not mounted !!"
fi



/etc/init.d/nginx start && php-fpm
