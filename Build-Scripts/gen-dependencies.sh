#!/usr/bin/env bash

HOMEBREW_BIN="${HOMEBREW_ROOT:-/opt/homebrew}/bin"
if [ -d "$HOMEBREW_BIN" ] ; then
    PATH="$HOMEBREW_BIN:$PATH"
    export PATH
else
    echo "warning: $HOMEBREW_BIN doesn't exist. This build will likely fail."
    echo "warning: If homebrew is installed elsewhere, set the HOMEBREW_ROOT environment variable."
fi

PACKAGES="pidgin gtk-mac-integration-gtk2"
PIDGIN_PATH="$(pkg-config pidgin --variable=prefix)/bin/pidgin"
OTHER_CFLAGS="$(pkg-config $PACKAGES --cflags-only-other)"
OTHER_LDFLAGS="$(pkg-config $PACKAGES --libs-only-l) -bundle_loader ${PIDGIN_PATH}"
HEADER_SEARCH_PATHS="$(pkg-config $PACKAGES --cflags-only-I | sed 's/^-I//g;s/ -I/ /g')"
LIBRARY_SEARCH_PATHS="$(pkg-config $PACKAGES --libs-only-L | sed 's/^-L//g;s/ -L/ /g')"

cat <<EOF > "${PROJECT_DIR}/Dependencies.xcconfig"
// With Homebrew path = ${HOMEBREW_BIN}
OTHER_CFLAGS = \$(inherited) ${OTHER_CFLAGS}
OTHER_LDFLAGS = \$(inherited) ${OTHER_LDFLAGS}
HEADER_SEARCH_PATHS = \$(inherited) ${HEADER_SEARCH_PATHS}
LIBRARY_SEARCH_PATHS = \$(inherited) ${LIBRARY_SEARCH_PATHS}
EOF

