#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# Write gateway IP for reference
echo "$route_vpn_gateway" > /etc/s6-overlay/s6-rc.d/svc-openvpn/route_info
