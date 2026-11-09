# /storage/roms, shared like /storage/music: group users with setgid, so a
# container's RomM can manage it and new files stay in the group.
{
  systemd.services.storage-roms-permissions = {
    description = "Make /storage/roms group-writable for users";
    wantedBy = [ "multi-user.target" ];
    # Before the mount, /storage/roms is an empty directory.
    unitConfig.RequiresMountsFor = [ "/storage/roms" ];
    serviceConfig.Type = "oneshot";
    script = ''
      chgrp users /storage/roms
      chmod 2775 /storage/roms
    '';
  };
}
