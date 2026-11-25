#!/bin/sh

# build script for 64-bit numeric library tests

set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$REPO_ROOT/lib"
SRC_DIR="$REPO_ROOT/src"
TEST_DIR="$REPO_ROOT/test"

# test modules
TEST_LIBS="TestCard64Conv TestInt64Conv TestCard64RelOps TestInt64RelOps TestCard64BaseMath TestInt64BaseMath TestCard64PowLog"

# test programs 
TEST_PROGRAMS="VisualIOTest TestConv TestRelOps TestBaseMath TestPowLog"

cd "$TEST_DIR"

# clean tests
rm -f *.d *.r *.o *.s $TEST_PROGRAMS

# compile test interfaces
for mod in $TEST_LIBS; do
    echo "*** compiling $mod.def ***"
    mocka -d "$LIB_DIR" -d "$SRC_DIR" -d "$TEST_DIR" -s "$mod"
done

# compile test implementations
for mod in $TEST_LIBS; do
    echo "*** compiling $mod.mod ***"
    mocka -d "$LIB_DIR" -d "$SRC_DIR" -d "$TEST_DIR" -S -c "$mod"
done

# compile and build test programs
for prog in $TEST_PROGRAMS; do
    echo "*** building $prog ***"
    mocka -d "$LIB_DIR" -d "$SRC_DIR" -d "$TEST_DIR" -S -c "$prog"
    mocka -d "$LIB_DIR" -d "$SRC_DIR" -d "$TEST_DIR" -S -p "$prog"
done

# EOF
