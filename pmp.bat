set PMP_PROJECT_GROUP_ID=org.c64pectre
set PMP_PROJECT_ARTIFACT_ID=pedscii
set PMP_PROJECT_ARTIFACT_VERSION=1.0.0-SNAPSHOT
set PMP_PROJECT_PACKAGING=prg

set PMP_COMPILER=ca65
set PMP_COMPILER_CA65_OPTIONS=--ignore-case --feature bracket_as_indirect

set PMP_PACKAGER=ld65

set PMP_RUNNER=x64sc
set PMP_RUNNER_X64SC_OPTIONS=-config vice.ini -moncommands target/%PMP_PROJECT_ARTIFACT_ID%.vice-labels

