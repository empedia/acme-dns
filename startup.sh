#!/bin/sh

# Start acme-dns in the background
/usr/local/bin/acme-dns/acme-dns &

# Wait a moment for acme-dns to start listening on 127.0.0.1:53
sleep 2

# Start socat for UDP forwarding (IPv4 only via fly-global-services)
# Listen on fly-global-services:53 (UDP) and forward to 127.0.0.1:53 (UDP)
socat UDP-LISTEN:53,fork,bind=fly-global-services UDP:127.0.0.1:53 &

sleep 2

# Start socat for TCP forwarding (IPv6 only via [::])
# Listen on [::]:53 (TCP) and forward to 127.0.0.1:53 (TCP)
socat -6 TCP-LISTEN:53,fork,bind=2001:19f0:7400:882f:0:cee6:f83c:1 TCP:127.0.0.1:53 &

# Keep the script running in foreground so the container doesn't exit
wait