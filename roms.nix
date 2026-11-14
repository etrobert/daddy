# /storage/roms, shared like /storage/music: group users with setgid, so a
# container's RomM can manage it and new files stay in the group.
{
  systemd.services.storage-roms-permissions = {
    description = "Make /storage/roms group-writable for users";
    wantedBy = [ "multi-user.target" ];
    # Before the mount, /storage/roms is an empty directory.
    unitConfig.RequiresMountsFor = [ "/storage/roms" ];
    serviceConfig.Type = "oneshot";
    # The whole tree, not just the top: RomM made roms/ in its own group, which
    # locked users out of uploading into it.
    script = ''
      chgrp -R users /storage/roms
      chmod -R g+rwX /storage/roms
      find /storage/roms -type d -exec chmod g+s {} +
    '';
  };

  # Uploads over SFTP stay group-writable, so RomM can rename and delete them.
  services.openssh.sftpFlags = [ "-u" "0002" ];
}
