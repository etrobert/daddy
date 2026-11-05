# daddy

NixOS config for daddy, a shared OVH KS-STOR in Strasbourg.

The box applies `main` every 5 minutes, rebooting when the kernel changes. A
push that does not build is skipped and the box keeps its current system.

## Adding yourself

1. Copy `users/soft.nix` to `users/<you>.nix` with your name and SSH keys.
2. Add it to `modules` in `flake.nix`.
3. Open a PR. Once merged, `ssh <you>@51.91.29.38` works within 5 minutes.

## Transmission

Downloads land in `/storage/downloads`. Open the web UI through an SSH tunnel,
then browse to <http://localhost:9091>:

```sh
ssh -NL 9091:127.0.0.1:9091 <you>@51.91.29.38
```

Containers share this one instance, each serving it to its own tailnet at
`http://<container>:9091`. Anyone on that tailnet can use it, with no login.

slskd is shared the same way, at `http://<container>:5030`, with its usual login.

## Lidarr

One Lidarr, on the develop branch for plugins such as Tubifarry, imports into
`/storage/music`. Each container serves it to its own tailnet at
`http://<container>:8686`. Anyone on those tailnets can use it, with no login.

## Navidrome

Navidrome serves `/storage/music` at <https://navidrome.etiennerobert.com>, and
to each container's tailnet at `http://<container>:4533`, with its usual login.

## Your own container

A container gives you your own tailnet, with SSH and the shared Transmission on
it.

1. Add yourself as in [Adding yourself](#adding-yourself).
2. Add this to `modules` in `flake.nix`, with a name of at most 11 characters and
   a `subnet` no other container uses (1 is peira, 2 is paal):

   ```nix
   (import ./user-container.nix {
     name = "<you>";
     subnet = 3;
     user = ./users/<you>.nix;
   })
   ```

3. Once merged, join your tailnet once from the host:

   ```sh
   sudo nixos-container root-login <you>
   tailscale up
   ```

Then `ssh <you>@<you>` works over your tailnet.

## Join over WireGuard

daddy runs a WireGuard server for everyone in `wireguard-peers.nix`, at
`51.91.29.38:51820`, with public key `X3tAaXEYfw1KhFS6x2CjVepMIrHGo3AEWrhrIs6rqnU=`.
Over it, daddy is `10.234.0.1`: Navidrome on 4533, Lidarr on 8686, Transmission
on 9091 and slskd on 5030. Peers can't reach each other.

1. Get a public key: your WireGuard app makes a key pair for a new tunnel, and a
   FRITZ!Box already has one (in any of its WireGuard device configs, under
   `[Peer]`).
2. Add yourself to `wireguard-peers.nix` with a free `ip`, and open a PR.
3. Once merged, set up the tunnel with your `ip`:

   ```ini
   [Interface]
   # Your app fills in PrivateKey. Leave it out for a FRITZ!Box.
   Address = 10.234.0.<n>/24

   [Peer]
   PublicKey = X3tAaXEYfw1KhFS6x2CjVepMIrHGo3AEWrhrIs6rqnU=
   AllowedIPs = 10.234.0.0/24
   Endpoint = 51.91.29.38:51820
   PersistentKeepalive = 25
   ```

   On a FRITZ!Box, import it under Internet > Permit Access > VPN (WireGuard) >
   Add connection > Link networks, answering yes to the other side being set
   up already, and list your home network under `networks` in step 2.

Two peers' `networks` can't overlap. FRITZ!Boxes default to `192.168.178.0/24`,
so a second one has to change its home network first.
