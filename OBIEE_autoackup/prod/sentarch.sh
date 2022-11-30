#!/bin/sh
scp -r /data/Middleware/oas590/obires.bar msk-fpm-bi02:/home/servusr/obireserv/;
echo "...archive was sent successfully! Trying to SSH-connection...";
ssh msk-fpm-bi02 << EOF
echo "SSH-connection established! Go to replace reserved archive..."
cd $HOME
cp -r obireserv/obires.bar /tmp/
echo "archive replaced successfully. Go back to prod..."
EOF
exit
#!/bin/sh
scp -r /data/Middleware/oas590/obires.bar msk-fpm-bi02:/home/servusr/obireserv/;
echo "...archive was sent successfully! Trying to SSH-connection...";
ssh msk-fpm-bi02 << EOF
echo "SSH-connection established! Go to replace reserved archive..."
cd $HOME
cp -r obireserv/obires.bar /tmp/
echo "archive replaced successfully. Go back to prod..."
EOF
exit

#УЗ servusr
