# sansa-rockbox

Install Rockbox on a SanDisk Sansa Clip+ from Linux.

Rockbox Utility v1.5.1 is the official installer. On a current distro it fails in two ways:

- Every download fails with "SSL handshake failed". The AppImage's Qt needs OpenSSL 1.1, and current distros ship only OpenSSL 3 or later.
- The bootloader step asks for the original SanDisk firmware file, `clppa.bin`, which SanDisk no longer hosts.

`setup.sh` fixes both. It downloads Rockbox Utility, the OpenSSL 1.1 libraries from the Fedora 39 package, and the 01.02.16 firmware from Rockbox's mirror. It checks each download against a pinned SHA-256, and checks `clppa.bin` against the MD5 in Rockbox's mkamsboot source. It then installs a `rockbox-utility` launcher in `~/.local/bin`. Nothing is installed system-wide.

## Requirements

x86_64 Linux with `curl`, `unzip`, `rpm2cpio` and `cpio`. On Debian and Ubuntu, install the `rpm2cpio` and `cpio` packages.

## Install Rockbox

1. On the player, open Settings > System Settings > USB Mode and select MSC. In MTP mode, Rockbox Utility can't install to the player.
2. Run `./setup.sh`.
3. Plug in the player and make sure its drive is mounted. The player can drop its mount after a few minutes of idle. If it does, remount it with `udisksctl mount -b /dev/sdX`.
4. Run `rockbox-utility`. In Configure, set the mountpoint to the player's internal storage.
5. Click Install. When it asks for the original firmware, select the `clppa.bin` path that `setup.sh` printed.
6. When Rockbox Utility says the install is done, unplug the player. It shows "firmware update in progress", flashes the bootloader, and turns off. Turn it on, and it boots Rockbox.

Rockbox Utility logs "Permission denied ... raw disc access" while it detects the player. You can ignore this. Only iPods and the older Sansa e200 and c200 need raw disk access.

## After the install

- Rockbox uses the same USB ID as the stock firmware and shows both the internal storage and the microSD card as USB drives.
- To make Rockbox's database include new songs, run Settings > General Settings > Database > Update Now on the player. The file browser shows new files without this step.
- Before you unplug the player, run `sync`, then `udisksctl unmount -b <device>` for each of its drives.

## Go back to the stock firmware

- To boot the stock firmware once, hold Left while you turn the player on. The stock firmware doesn't boot while the player is powered over USB.
- To remove Rockbox, copy the unmodified `clppa.bin` to the root of the internal storage. Boot the stock firmware with Left held and let it flash. Then delete `.rockbox`.

## License

AGPL-3.0. See [LICENSE](LICENSE).
