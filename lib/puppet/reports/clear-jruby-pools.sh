#!/bin/bash
# GIST_URL: https://gist.github.com/natemccurdy/13e3b2d8477dbd6bd01d
# Run this on a puppetserver to delete its JRuby pools to clear their cache.
# A response of "HTTP/1.1 204 No Content" means it worked.
#
# https://docs.puppetlabs.com/puppetserver/latest/admin-api/v1/jruby-pool.html

CONFDIR="$(puppet master --configprint confdir)"

CERT="$(puppet master --confdir "${CONFDIR}" --configprint hostcert)"
PRIVKEY="$(puppet master --confdir "${CONFDIR}" --configprint hostprivkey)"
CACERT="$(puppet master --confdir "${CONFDIR}" --configprint localcacert)"

/opt/puppetlabs/puppet/bin/curl -s -i -X DELETE \
                                --cert "$CERT" \
                                --key "$PRIVKEY" \
                                --cacert "$CACERT" \
                                "https://$(hostname -f):8140/puppet-admin-api/v1/jruby-pool"

