../openssl/openssl.exe genrsa -des3 -out rootCA.key -passout pass:password 4096
../openssl/openssl.exe req -x509 -new -nodes -key rootCA.key -sha256 -days 365 -out rootCA.crt -config CAopts.conf -passin pass:password
../openssl/openssl.exe genrsa -out server.key 2048 -config opts.conf
../openssl/openssl.exe req -new -key server.key -out server.csr -config opts.conf
../openssl/openssl.exe x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 365 -sha256 -passin pass:password -extfile v3.ext