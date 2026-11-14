# sansa-rockbox

A setup script and notes for installing Rockbox on a Sansa Clip+ from Linux with the official Rockbox Utility.

## Direction

- Keep it one POSIX shell script with no build step.
- Pin every download to a SHA-256. Never commit `clppa.bin` or other SanDisk files. Download them.
- Install per user, under `$HOME`. Nothing system-wide.
- Check claims about Rockbox behavior against the Rockbox source or manual, not memory.

## Glossary

- **OF**: original firmware, SanDisk's stock firmware.
- **clppa.bin**: the Clip+ OF image. Rockbox Utility patches it with the bootloader.
- **MSC**: USB mass storage mode. Rockbox Utility needs it. MTP mode doesn't work.
- **AMS**: the Sansa chip family (Clip+, Clip Zip, Fuze v2). These install by flashing a patched OF file, not by writing raw sectors.
