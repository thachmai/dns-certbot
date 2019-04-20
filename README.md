# Painless letsencrypt TLS certificate via DNS challenge

This docker image simplifies the process of obtaining and renewing TLS certificates with [letsencrypt](https://letsencrypt.org). It works with both single domain certificate and [wildcard certificate](https://en.wikipedia.org/wiki/Wildcard_certificate).

By using the service provided by [acme-dns](https://github.com/joohoi/acme-dns), you will no longer need to modify the DNS record for each ACME challenge. Thus, the TLS obtention/renewal process becomes *simpler*, *automated* and *safer*.

For more information on the technical details, please refer to [my blog post](https://www.thachmai.info/2019/04/18/painless-letsencrypt-wildcard/).

## To obtain a wildcard certificate for the domain `*.demo.tested.science`
### 1. Generate the DNS challenge
```bash
$ docker run -it --rm -v /etc/letsencrypt:/etc/letsencrypt thachmai/dns-certbot certonly -d '*.demo.tested.science'
```
The command should prompt you to add a CNAME record to your DNS:
```
Output from acme-dns-auth.py:
Please add the following CNAME record to your main DNS zone:
_acme-challenge.demo.tested.science CNAME 71f61204-bd63-48ba-bb60-55035347be93.auth.acme-dns.io.

Waiting for verification...

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Challenges loaded. Press continue to submit to CA. Pass "-v" for more info about
challenges.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
```

### 2. Add the DNS CNAME record
In another shell, follow the instruction given by `acme-dns-auth.py`: add a CNAME record for `_acme-challenge.demo.tested.science` pointing to `71f61204-bd63-48ba-bb60-55035347be93.auth.acme-dns.io.` (don't forget the ending `.`). The CNAME record can take a few minutes to propagate.

Verify the DNS progation status with:
```bash
$ dig +short @1.1.1.1 _acme-challenge.demo.tested.science txt
71f61204-bd63-48ba-bb60-55035347be93.auth.acme-dns.io.
"StWEuujYKUevmFYRt468AUnP_j49-YH3z38elFOoBgE"
```
If `dig` doesn't return any value, it means that the CNAME value hasn't been progated. You should retry the `dig` command again after a few minutes until it returns a value.

### 3. Finish the DNS challenge
Return to the `dns-certbot` shell and hit <ENTER> to terminate the challenge.
```
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

### 4. Renew the certificate
```bash
$ docker run --rm -it -v /etc/letsencrypt:/etc/letsencrypt thachmai/dns-certbot renew
```
You should run that command in a cron daily job.

## Certificate and config location
The certificates and configuration are stored in `/etc/letsencrypt`, you'll need root access.


## Simpler usage with shell alias
If you use the command often, a shell alias can simplify the command execution (to be placed in `~/.bashrc` for example)
`alias dns-certbot='docker run -it --rm -v /etc/letsencrypt:/etc/letsencrypt thachmai/dns-certbot'`

After that, requesting a certificate is simply `dns-certbot certonly -d '*.demo.tested.science'`
Renew all certificates becomes `dns-certbot renew`
