# daddy

NixOS config for daddy, a shared OVH KS-STOR in Strasbourg.

The box applies `main` every 5 minutes, rebooting when the kernel changes. A
push that does not build is skipped and the box keeps its current system.

## Adding yourself

1. Copy `users/soft.nix` to `users/<you>.nix` with your name and SSH keys.
2. Add it to `modules` in `flake.nix`.
3. Open a PR. Once merged, `ssh <you>@51.91.29.38` works within 5 minutes.

## Transmission

Downloads land in `/storage/downloads`. Containers reach the web UI at their
host address, port 9091, with no login. From elsewhere, open it through an SSH
tunnel, then browse to <http://localhost:9091>:

```sh
ssh -NL 9091:127.0.0.1:9091 <you>@51.91.29.38
```

## Paal's container

`paal` runs Tailscale on its own tailnet. After the first deploy, Paal joins it
once from the host:

```sh
sudo nixos-container root-login paal
tailscale up
```

Then `ssh paal@paal` works over the tailnet.
