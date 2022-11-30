#!/bin/sh
DOMAIN_HOME="/data/Middleware/oas590/user_projects/domains/bi"
export DOMAIN_HOME
/data/Middleware/oas590/bi/modules/oracle.bi.metadatalcm/scripts/exportarchive.sh ssi /data/Middleware/oas590/obires.bar encryptionpassword='Admin123' ## > /dev/null 2>&1;
echo "export done! Sending process started..."
