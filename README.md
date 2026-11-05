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
