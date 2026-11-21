#!/bin/sh

# build script for 64-bit numeric libraries

set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$REPO_ROOT/lib"
SRC_DIR="$REPO_ROOT/src"

# modules in dependency order
MODULES="NumStatus LongCardMath NumStatusIO LongCardIO CARD64 Card64IO INT64 Int64IO"

cd "$SRC_DIR"

# clean 
for mod in $MODULES; do
  rm -f "$mod.d" "$mod.r" "$mod.o" "$mod.s"
done

# compile interfaces
for mod in $MODULES; do
  mocka -d "$LIB_DIR" -d "$SRC_DIR" -s "$mod"
done

# compile implementations
for mod in $MODULES; do
  mocka -d "$LIB_DIR" -d "$SRC_DIR" -S -c "$mod"
done

# EOF
