#!/bin/sh
# Sets up Rockbox Utility for a Sansa Clip+ on a current Linux distro.
set -eu

APPIMAGE_URL=https://download.rockbox.org/rbutil/linux/RockboxUtility-v1.5.1.AppImage
APPIMAGE_SHA256=0a9743eac53daa3006cfa2b048119da2ac748d58ab8821a9fe002e51cdf72c22
SSL_URL=https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/39/Everything/x86_64/os/Packages/o/openssl1.1-1.1.1q-5.fc39.x86_64.rpm
SSL_SHA256=6ea789cb9df4138e91f7466a742cfb08129a72e0179c4a556cba3053ed16f753
FW_URL=https://download.rockbox.org/sansa_fw/clipplus01.02.16.zip
FW_SHA256=dbc3a02f8a14aba6090670b3a9e32c68520ecf7d4b3bc7ce66681f10159d369d
# clppa.bin 01.02.16, from the table in Rockbox's utils/mkamsboot/mkamsboot.c
CLPPA_MD5=055a53de1dfb09f6cb71c504ad48bd13

APP_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/rockbox-utility
LIB_DIR=$APP_DIR/openssl1.1
BIN=$HOME/.local/bin/rockbox-utility

for tool in curl sha256sum md5sum unzip rpm2cpio cpio; do
    command -v "$tool" >/dev/null || { echo "missing: $tool" >&2; exit 1; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fetch() { # url sha256 dest
    curl -fsSL -o "$3" "$1"
    echo "$2  $3" | sha256sum -c --quiet
}

mkdir -p "$APP_DIR" "$LIB_DIR" "$(dirname "$BIN")"

fetch "$APPIMAGE_URL" "$APPIMAGE_SHA256" "$tmp/rbutil.AppImage"
install -m 755 "$tmp/rbutil.AppImage" "$APP_DIR/RockboxUtility.AppImage"

# The AppImage's Qt loads OpenSSL 1.1 at runtime for HTTPS. Without it,
# every download fails with "SSL handshake failed".
fetch "$SSL_URL" "$SSL_SHA256" "$tmp/openssl1.1.rpm"
(cd "$tmp" && rpm2cpio openssl1.1.rpm | cpio -idm --quiet './usr/lib64/libssl.so.1.1*' './usr/lib64/libcrypto.so.1.1*')
cp -a "$tmp"/usr/lib64/* "$LIB_DIR/"

fetch "$FW_URL" "$FW_SHA256" "$tmp/fw.zip"
unzip -q -o "$tmp/fw.zip" clppa.bin -d "$tmp"
echo "$CLPPA_MD5  $tmp/clppa.bin" | md5sum -c --quiet
cp "$tmp/clppa.bin" "$APP_DIR/clppa.bin"

cat > "$BIN" <<EOF
#!/bin/sh
LD_LIBRARY_PATH="$LIB_DIR\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" exec "$APP_DIR/RockboxUtility.AppImage" "\$@"
EOF
chmod 755 "$BIN"

echo "Run: rockbox-utility"
echo "Original firmware for the bootloader step: $APP_DIR/clppa.bin"
