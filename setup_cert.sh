#!/usr/bin/env bash
# One-time setup: creates a persistent self-signed code-signing certificate.
# After this, TCC (Privacy permissions) recognises the app by a stable identity
# that survives every rebuild — no more "Accessibility not granted" after updates.
set -euo pipefail

CERT_NAME="ClipboardManager Dev"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-certificate -c "$CERT_NAME" "$KEYCHAIN" &>/dev/null; then
    echo "Certificate '$CERT_NAME' already exists — nothing to do."
    exit 0
fi

echo "Creating code-signing certificate '$CERT_NAME'..."

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# LibreSSL-compatible config (no -addext flag needed)
cat > "$TMP/cert.conf" <<'CONF'
[req]
distinguished_name = dn
x509_extensions    = ext
prompt             = no
[dn]
CN = ClipboardManager Dev
[ext]
keyUsage           = critical,digitalSignature
extendedKeyUsage   = critical,codeSigning
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always
basicConstraints   = CA:false
CONF

/usr/bin/openssl req -x509 -newkey rsa:2048 \
    -keyout "$TMP/key.pem" -out "$TMP/cert.pem" \
    -days 3650 -nodes -config "$TMP/cert.conf" 2>/dev/null

/usr/bin/openssl pkcs12 -export \
    -out "$TMP/cert.p12" -inkey "$TMP/key.pem" -in "$TMP/cert.pem" \
    -passout pass: 2>/dev/null

# Import (you may be prompted for your login keychain password)
security import "$TMP/cert.p12" -k "$KEYCHAIN" -P "" \
    -T /usr/bin/codesign -T /usr/bin/security

# Trust for code signing in the login keychain
security add-trusted-cert -r trustRoot -p codeSign \
    -k "$KEYCHAIN" "$TMP/cert.pem"

echo ""
echo "Done. '$CERT_NAME' is in your login keychain."
echo "Run ./run.sh to rebuild and launch with stable signing."
