#!/bin/sh
echo "--- Port 53 Listeners BEFORE ACME DNS ---"
ss -tulnp | grep ':53'
echo "--------------------------------------------------"
# Start acme-dns in the background
/usr/local/bin/acme-dns/acme-dns &

# Wait a moment for acme-dns to start listening on 127.0.0.1:53
sleep 2

echo "--- Port 53 Listeners AFTER ACME DNS BEFORE SOCAT UDP---"
ss -tulnp | grep ':53'
echo "--------------------------------------------------"

# Start socat for UDP forwarding (IPv4 only via fly-global-services)
# Listen on fly-global-services:53 (UDP) and forward to 127.0.0.1:53 (UDP)
socat UDP-LISTEN:53,fork,bind=fly-global-services UDP:127.0.0.1:53 &

sleep 2
echo "--- Port 53 Listeners AFTER UDP SOCAT BEFORE TCP SOCAT---"
ss -tulnp | grep ':53'
echo "--------------------------------------------------"

# Start socat for TCP forwarding (IPv6 only via [::])
# Listen on [::]:53 (TCP) and forward to 127.0.0.1:53 (TCP)
socat -6 -d -d TCP-LISTEN:53,fork,bind=[::] TCP:127.0.0.1:53 &

echo "--- Port 53 Listeners AFTER TCP SOCAT ---"
ss -tulnp | grep ':53'
echo "--------------------------------------------------"

# Keep the script running in foreground so the container doesn't exit
wait