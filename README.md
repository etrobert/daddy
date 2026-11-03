# daddy

NixOS config for daddy, a shared OVH KS-STOR in Strasbourg.

The box applies `main` every 5 minutes, rebooting when the kernel changes. A
push that does not build is skipped and the box keeps its current system.

## Adding yourself

1. Copy `users/soft.nix` to `users/<you>.nix` with your name and SSH keys.
2. Add it to `modules` in `flake.nix`.
3. Open a PR. Once merged, `ssh <you>@51.91.29.38` works within 5 minutes.

## Transmission

Downloads land in `/storage/downloads`. On the tailnet, the web UI is at
<http://100.117.28.35:9091>, with no login, so anyone on the tailnet can use it.

Otherwise, open it through an SSH tunnel, then browse to <http://localhost:9091>:

```sh
ssh -NL 9091:127.0.0.1:9091 <you>@51.91.29.38
```

## Tailscale

After the first deploy, someone runs `sudo tailscale up` on the box and opens
the login link it prints to add daddy to the tailnet.

## Soularr

Runs every 5 minutes once `/etc/soularr.ini` exists, placed by hand with mode
600. Base it on [the example](https://github.com/mrusse/soularr/blob/v1.2.3/config.ini).
Under `[Slskd]`, use `http://127.0.0.1:5030` and `/var/lib/slskd/downloads`, with
the API key set as `SLSKD_API_KEY` in `/etc/slskd.env`. Under `[Lidarr]`, use
Lidarr's tailnet IP, as daddy does not use Tailscale DNS.
