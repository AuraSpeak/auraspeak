#!/usr/bin/env bash
# Verhindert Commits, wenn <<...>> Platzhalter in den zu prüfenden Dateien stehen.
# pre-commit übergibt die Dateiliste (beim Commit: gestagte; bei --all-files: alle).
# Wichtig: Änderungen an diesem Skript vor dem Commit stagen, sonst läuft die alte Version (pre-commit stasht unstaged).

set -e

if [ $# -eq 0 ]; then
  exit 0
fi

# Diese Dateien enthalten das Muster nur zur Dokumentation – von der Prüfung ausnehmen.
# Relativ und absolut (pre-commit kann absolute Pfade übergeben).
filtered=()
for f in "$@"; do
  case "$f" in
    .pre-commit/check-placeholders.sh|.pre-commit-config.yaml|*/.pre-commit/check-placeholders.sh|*/.pre-commit-config.yaml) ;;
    *) filtered+=("$f") ;;
  esac
done

if [ ${#filtered[@]} -eq 0 ]; then
  exit 0
fi

# Suche nach <<...>> (z. B. <<$TEXT>>, <<LINK HERE>>)
if grep -n -E '<<[^>]*>>' "${filtered[@]}" 2>/dev/null; then
  echo ""
  echo "Fehler: Platzhalter <<...>> gefunden."
  echo "Bitte ersetze alle <<...>> vor dem Commit."
  exit 1
fi

exit 0
