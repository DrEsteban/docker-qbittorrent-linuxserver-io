#!/usr/bin/env bash

# Remove process and route information when connection closes
rm -rf /etc/s6-overlay/s6-rc.d/svc-openvpn/pia_pid /etc/s6-overlay/s6-rc.d/svc-openvpn/route_info
