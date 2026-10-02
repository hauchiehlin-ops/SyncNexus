#!/bin/zsh
# One-time: create a local self-signed code-signing identity in a dedicated keychain
# (~/.syncnexus-signing). Signing every build with the SAME certificate keeps the app's identity
# stable, so macOS privacy grants (Full Disk Access, removable volumes) survive rebuilds.
# Nothing is added to your login keychain and no Apple Developer account is needed.
set -euo pipefail
DIR=~/.syncnexus-signing
KC="$DIR/signing.keychain-db"
NAME="SyncNexus Local Signing"
if [[ -f "$KC" && -f "$DIR/keychain-password" && -f "$DIR/.complete" ]]; then echo "signing identity already set up: $KC"; exit 0; fi
mkdir -p "$DIR"; chmod 700 "$DIR"
PW=$(openssl rand -hex 16); print -rn -- "$PW" > "$DIR/keychain-password"; chmod 600 "$DIR/keychain-password"
cat > "$DIR/openssl.cnf" <<CNF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
CNF
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -config "$DIR/openssl.cnf" -keyout "$DIR/key.pem" -out "$DIR/cert.pem" 2>/dev/null
openssl pkcs12 -export -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -macalg sha1 -inkey "$DIR/key.pem" -in "$DIR/cert.pem" -name "$NAME" -passout pass:"$PW" -out "$DIR/identity.p12"
security create-keychain -p "$PW" "$KC"
security set-keychain-settings "$KC"                       # never auto-lock
security unlock-keychain -p "$PW" "$KC"
security import "$DIR/identity.p12" -k "$KC" -P "$PW" -T /usr/bin/codesign >/dev/null
security set-key-partition-list -S apple-tool:,apple: -s -k "$PW" "$KC" >/dev/null
rm -f "$DIR/key.pem" "$DIR/identity.p12"
chmod 600 "$KC" 2>/dev/null || true
touch "$DIR/.complete"
echo "created signing identity '$NAME' in $KC"
