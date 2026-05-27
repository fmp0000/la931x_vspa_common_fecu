# Regression TODO

## Ziele

- Reproduzierbare Cycle-Regression fuer alle Kernel mit Test-Harness.
- Specs automatisch mit aktuellen Runsim-Cycles versorgen.
- Submodule-freundlichen Docker-Workflow dokumentieren.

## Sofort (diese Woche)

- [x] venv im Super-Repo einrichten (.venv)
- [x] Docker-Container vspa-unified fuer Runsim verifizieren
- [x] Pilot- und Stabilitaetsmessung (mehrfach) auf reprasentativen Kerneln
- [x] Cycle-Werte in erste 10 Kernel-Specs aktualisieren
- [x] Regression-Skript fuer alle Tests anlegen: scripts/regression_cycles_all.sh

## Als Naechstes

- [ ] Voll-Lauf ueber alle Kernel mit tests/<kernel>/Makefile
- [ ] Ergebnisreport als CSV/Markdown in build/reports ablegen
- [ ] FAIL-Faelle triagieren (compile/sim/mismatch)
- [ ] Verbleibende Spec-Templates (not_started) fuer perf/cycles nachziehen
- [ ] Optional: status-Felder in Specs auf sim_verified angleichen, wenn PASS stabil

## Submodule Docker-Workflow

- [ ] Im Submodule eine kurze README fuer Test-Execution anlegen
- [ ] Wrapper-Skript im Submodule, das den Super-Repo-Runner aufruft
- [ ] Klarstellen, welche Schritte im Host und welche im Container laufen

## Script vs Pytest

Empfehlung: Hybrid.

- Primar: ein dediziertes Shell/Python-Regression-Skript fuer Build+Runsim+Cycle-Messung.
  Grund: Toolchain/Container/Log-Parsing sind pipeline-orientiert, nicht Unit-Test-orientiert.
- Optional zusaetzlich: pytest als orchestrierende Huelle (smoke + assertions auf Report-Datei),
  aber nicht als Ersatz fuer den eigentlichen Runsim-Runner.

## Akzeptanzkriterien

- Jeder Kernel mit vorhandener Test-Harness liefert PASS oder klaren FAIL-Grund.
- Cycle-Wert ist pro Kernel stabil (z. B. median aus 3 Runs).
- Report ist versionierbar und maschinenlesbar.
