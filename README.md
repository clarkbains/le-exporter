# LE Exporter
LE exporter is a small utility I made to help manage certificates with a Hashistack deployment. If you run web services, you will most likely want a reverse proxy, allowing multiple services to be load balanced, and to be available from a single IP. Traefik and Fabio both are good examples of this, and they each have good support for consul, which means that there is 0 reverse-proxy configuration needed for deploying new applications (except some labels on each job you want accessible)

## SSL
SSL provides a layer of encyption that should be used with any public facing web service. With ACME providers like LetsEncrypt giving out free certificates, there are very few reasons to not use SSL/TLS with all your web applications


## The Issue
Traefik provides a super simple mechanism for automatically getting and using certificates from LetsEncrypt, but the community version is unable to operate in a HA (High availability) mode and still be able to handle getting and using LetsEncypt certs. If you want to run HA traefik, you would have to have it read from some shared source of certificates, that every instance can get to. Hashicorp's Vault would be perfect for this, however it is not supported as a certificate store in the community version of Traefik.

Fabio is unable to get letsencypt certificates automatically, however it can integrate with vault, and retrieve them from there. Since it doesn't handle any of the state required when you go through the letsencypt cert request process, there is no state that would prevent it from being used in HA.

The issue then, is that you are left chosing between no HA and easy certificates (traefik & LE), HA and complicated certificate generation/distribution (traefik & synched cert stores) or HA and no easy certs (Fabio)

## The solution
By taking some features from each, and leveraging other functionality in the software stack, I created a tool that helps simplify the 2nd option, HA and complicated certificate generation/distribution, using traefik as the proxy, and vault as the certificate storage. 
This tool does the following:

- Watches a consul K/V entry for any domains
- Watches consul service tags for domains in traefik style configuration ``Host(`domain.tld`)`` 
- Uses list of domains and letsencrypt to generate new certificates for newly found domains
- Sends generated certificates (key and fullchain) into vault at a configurable path
- Periodically renews certificates stored in vault
- Periodically purges certificates no longer required by consul kv/catalog out of vault (configurable)

As mentioned, traefik does not support gettings certificates out of vault, while fabio natively does. While I have used this with fabio, I prefer some of the features available in traefik, so there is additionally [cert-agg](github.com/clarkbains/traefik-cert-aggregator), which is a tool & nomad configuration that will get the certificates from vault, and pass them to each traefik instance. This allows for HA, with traefik, and letsencrypt, as well as secure certificate storage in vault. Some more information about the setuo is available in the project readme.

## TODO
le-exporter does not have proper error handling for when it finds a "domain" in consul catalog that is not a proper domain, so it could possibly rate limit itself requesting invalid certificates with the ACME provider.
le-exporter is not very configurable at the moment, in terms of blacklisted domains for cert generation. I intend to add this to the consul k/v integration, so it is centralized

