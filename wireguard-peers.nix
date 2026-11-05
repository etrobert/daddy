# Everyone connecting to daddy over WireGuard. To join, add yourself with:
#   name       who you are
#   publicKey  your device's or router's public key; its private key stays with you
#   ip         a free address in 10.234.0.0/24 (.1 is daddy)
#   networks   networks behind you that should reach daddy, e.g. your home
#              network when a router connects. Each must be unique among peers.
# Then see "Join over WireGuard" in the README.
[
  {
    name = "paal";
    # His FRITZ!Box, connected with "Link networks"; it has one key pair for all
    # its WireGuard connections.
    publicKey = "mqotR4eXHsRQIWu/4Ue2nkC2ASYx0fRhlZHkqno4/AA=";
    ip = "10.234.0.2";
    networks = [ "192.168.10.0/24" ];
  }
]
