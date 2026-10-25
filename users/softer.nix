{
  users.users.softer = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDh7EkXQRh5WvlUdKbCqaijOg8GAyB+NMxOHG52SOiCAePzPz+kupyBoFc/6iNIJ5ZZpDEPmO63brpuXpB9CUXJOWOtqJJgBfgfhd2bhfCoO/JMfvMhhuft1pkHtOqtj82dWOI+uMSFva0aHtmK47SVjj/sMSzqEaYcq7MW0DIY8VxTpNIdUwi/4yxwx84LNwb2qdgbIT48gryQcBULvq+xmE4ahc+IcOEI2FGK+QAjhDhw0mAWzDiR8osJbVDUoMb8JT/NivzbUYIUoQTWimbU6lF78zhF45G3ZgLhPsv/cxe1+fml2mAJ6xbEYgravFCEm1sflJhfifkY+MmQSZKT openpgp:0xAFAB3D32"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK5yGDpi6kPb/mu2pQUpVPffdu0lYvzQVSgqNpAt1eqP openpgp:0xB54D920D"
    ];
  };
}
