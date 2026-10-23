#!/bin/sh
# Run every TypeQL file against a real TypeDB server using the distribution
# in this folder (start it with:  ./typedb-all-mac-arm64-3.14.1/typedb server).
# Recreates the `ecommerce` database, then runs each queries/*.tql in order —
# schema files in a schema transaction, insert files in write, the rest in read.
# EXPECTED failures: 05 (second email violates @key at commit) and
# 10 (good doesn't own warranty-expired-date — type error).
cd "$(dirname "$0")"
DIST="${TYPEDB_DIST:-typedb-all-mac-arm64-3.14.1}"
ADDR="${TYPEDB_ADDRESS:-localhost:1729}"
DB=ecommerce
console() {
  "./$DIST/typedb" console --address "$ADDR" --username admin --password password \
    --tls-disabled --diagnostics-disabled "$@"
}

console --command "database delete $DB" >/dev/null 2>&1
console --command "database create $DB" >/dev/null || { echo "cannot reach TypeDB at $ADDR"; exit 1; }

fail=0
for f in queries/*.tql; do
  case "$f" in
    *schema*)  tx=schema; end=commit ;;
    *insert*)  tx=write;  end=commit ;;
    *)         tx=read;   end=close  ;;
  esac
  printf '=== %s (%s)\n' "$f" "$tx"
  if console --command "transaction $tx $DB" \
             --command "source $f" \
             --command "$end" >/dev/null 2>&1; then
    echo "--- OK"
  else
    echo "--- FAILED"
    case "$f" in *05-insert-second-email*|*10-query-good-warranty*) ;; *) fail=1 ;; esac
  fi
done
exit $fail
