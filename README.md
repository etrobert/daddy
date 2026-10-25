# daddy

NixOS config for daddy, a shared OVH KS-STOR in Strasbourg.

The box applies `main` every 5 minutes, rebooting when the kernel changes. A
push that does not build is skipped and the box keeps its current system.

## Adding yourself

1. Copy `users/soft.nix` to `users/<you>.nix` with your name and SSH keys.
2. Add it to `modules` in `flake.nix`.
3. Open a PR. Once merged, `ssh <you>@51.91.29.38` works within 5 minutes.

## Adding a ZFS dataset

Nothing creates datasets on the running box, so create it before merging the
PR that declares it in `disko.nix`, with the same options:

```sh
sudo zfs create -o <property>=<value> storage/<name>
```
