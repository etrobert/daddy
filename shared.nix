# /storage/shared holds files used by people and services alike; members of
# the shared group can read and write all of it.
{
  # Fixed so the same group can be created inside VMs that mount the share.
  users.groups.shared.gid = 2000;

  # setgid keeps new files in the group, and the default ACL keeps them
  # group-writable whatever umask their creator has.
  systemd.tmpfiles.rules = [
    "d /storage/shared 2775 root shared -"
    "A+ /storage/shared - - - - default:group:shared:rwx"
  ];
}
