# daddy

NixOS config for daddy, a shared OVH KS-STOR in Strasbourg.

The box applies `main` every 5 minutes, rebooting when the kernel changes. A
push that does not build is skipped and the box keeps its current system.

## Adding yourself

1. Copy `users/soft.nix` to `users/<you>.nix` with your name and SSH keys.
2. Add it to `modules` in `flake.nix`.
3. Open a PR. Once merged, `ssh <you>@51.91.29.38` works within 5 minutes.

## Shared files

`/storage/shared` is writable by everyone in the `shared` group, which every
user in `users/` joins. New files stay group-writable. Each service that
writes there gets its own directory, `/storage/shared/<service>`.

## Transmission

Downloads go to `/storage/shared/transmission`. The web UI is only reachable by
the `shared` group, through an SSH tunnel:

```sh
ssh -NL 9091:/run/transmission/rpc.sock <you>@51.91.29.38
```

Then open <http://localhost:9091>.
