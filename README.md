# Painless letsencrypt TLS certificate via DNS challenge

This docker image simplifies the process of obtaining and renewing TLS certificates with [letsencrypt](https://letsencrypt.org). It works with both single domain certificate and [wildcard certificate](https://en.wikipedia.org/wiki/Wildcard_certificate).

By using the service provided by [acme-dns](https://github.com/joohoi/acme-dns), you will no longer need to modify the DNS record for each ACME challenge. Thus, the TLS obtention/renewal process becomes *simpler*, *automated* and *safer*.

For more information on the technical details, please refer to [my blog post](https://www.thachmai.info/2019/04/18/painless-letsencrypt-wildcard/).

## To obtain a wildcard certificate for the domain `*.demo.tested.science*`
### 1. Generate the challenge
```bash
$ docker run -it -v /etc/letsencrypt:/etc/letsencrypt thachmai/dns-certbot certonly -d '*.demo.tested.science'
```
The command should terminate with error
```
Output from acme-dns-auth.py:
Please add the following CNAME record to your main DNS zone:
_acme-challenge.demo.tested.science CNAME 5456708c-6c6f-4fd2-a3d4-fb9384aa8121.auth.acme-dns.io.

Waiting for verification...
Cleaning up challenges
Failed authorization procedure. demo.tested.science (dns-01): urn:ietf:params:acme:error:dns :: DNS problem: NXDOMAIN looking up TXT for _acme-challenge.demo.tested.science 
```

### 2. Add the DNS CNAME record
Follow the instruction given by `acme-dns-auth.py`: add a CNAME record for `_acme-challenge.demo.tested.science` pointing to `5456708c-6c6f-4fd2-a3d4-fb9384aa8121.auth.acme-dns.io.` (don't forget the ending `.`). The CNAME record can take a few minutes to propagate. Verify its progapation with:
```bash
$ dig +short @1.1.1.1 _acme-challenge.demo.tested.science txt
5456708c-6c6f-4fd2-a3d4-fb9384aa8121.auth.acme-dns.io.
"lW0fReLNphoPs7eQyMK0UEksj5WpUZrlR8ijyiWnzxA"
```
If `dig` doesn't return any value, you should wait until the DNS value is progapaged.

### 3. Generate the certificate
Rerun the first command
```bash
$ docker run -it -v /etc/letsencrypt:/etc/letsencrypt thachmai/dns-certbot certonly -d '*.demo.tested.science'
```
This time, the command should terminate successfully
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None                                                                                                                                       
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for test.tested.science
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/test.tested.science/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/test.tested.science/privkey.pem
   Your cert will expire on 2019-07-18. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
```

## Certificate and config location
The certificates and configuration are stored in `/etc/letsencrypt`, you'll need root access.

## Renew the certificate
```bash
$ docker run --rm -it -v /etc/letsencrypt:/etc/letsencrypt thachmai/dns-certbot renew
```
You should run that command in a cron daily job.
