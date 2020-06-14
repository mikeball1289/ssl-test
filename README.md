# NodeJS with SSL quickstart

## The problem

We want to be able to build nodejs servers using https on localhost to mirror a production environment, and the easiest way to do that is to use the built-in https module. However this module requires we provide our own ssl certificates for localhost. We want a self-signed certificate that can be accepted by both common browsers and other nodejs client applications. That means we need a certificate that identifies itself as localhost, and is signed by a trusted CA. This is made a little bit harder by the fact that we're working on Windows.

## The Process

First we need some [openssl binaries](https://wiki.openssl.org/index.php/Binaries) that have been built for Windows. Download those and link them in your PATH. All of the commands we're running here are in Powershell and assume you have access to a standard implementation of openssl.

Then we'll create a CA keypair, which we'll call localCA, which we can use for signing. We put these options in [a configuration file](../blob/master/ssl/CAopts.conf) and create the keypair
```
openssl genrsa -des3 -out rootCA.key -passout pass:password 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 365 -out rootCA.crt -config CAopts.conf -passin pass:password
```

Notably we need a root CA so that the server certificate we generate is properly signed and chained, and the CA's common name needs to be different from our server certificate's common name so it doesn't appear self-signed.

Next we put the options for our server certificate in [its own configuration file](../blob/master/ssl/opts.conf), and also create a [file for its v3 extension options](../blob/master/ssl/v3.ext). The extension options define our certificate's alternate domains and intended usage. If these are missing Chrome will reject our certificate no matter what else we do. Finally we can generate a server keypair
```
openssl genrsa -out server.key 2048 -config opts.conf
openssl req -new -key server.key -out server.csr -config opts.conf
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 365 -sha256 -passin pass:password -extfile v3.ext
```

## Checking that it worked

### NodeJS

You can run everything above by downloading this repository and running `npm run ssl` from Powershell. Then you can run `npm start` to spin up a server using the certificates we generated, and `npm test` to run a client that makes a request against that server. If everything went right, the test command should output `pong`.

In order to make this work we needed to include this line in our client code
```
https.globalAgent.options.ca = [fs.readFileSync('ssl/rootCA.crt')];
```

Nodejs has its own CA store, and that line adds our own root CA's certificate to that store which causes node's https module to trust certificates signed by that CA.

### Chrome

Chrome uses Window's own certificate store, so we just need to install it there. Run `mmc` to open the Microsoft Management Console, then go to File > Add/Remove Snap-ins. Select Certificates > My User Account then click OK. Go into Trusted Root Certification Authorities, right click Certificates and select All Tasks > Import... . Hit Next and under File Name select the rootCA.crt file we created. Then hit Next until the end, click Finish, accept the warnings, and then your CA certificate is installed.

**_Warning_**: _Once installed make sure you keep your rootCA.key file **private** and **secure**. Having it installed means that your computer will automatically trust any certificate signed with it, so if an attacker gets control of it they can effectively make your computer trust anything._

With that certificate installed, we should be able to navigate to `https://localhost:8080` in Chrome and see our server's response with no warnings, and a lock icon beside the URL indicating that our connection is secure.

### Firefox

Like node, Firefox uses its own root CA store. We can manage the store by going to the security settings at `about:preferences#privacy`, and clicking View Certificates under the Certificates header. Click Import..., select `rootCA.crt` and check Trust this CA to identify websites, then click OK.

Once that's complete we can navigate to `https://localhost:8080` and if everything went right we should get no errors and once again have a lock beside the URL, indicating that the connection is secure.