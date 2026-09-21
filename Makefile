.PHONY: tools quota cluster access arc runners test status cleanup all
tools:    ; @scripts/00-tools.sh
quota:    ; @scripts/01-quota.sh
cluster:  ; @scripts/02-cluster.sh
access:   ; @scripts/03-access.sh
arc:      ; @scripts/04-arc.sh
runners:  ; @scripts/05-runners.sh
test:     ; @scripts/06-test.sh
status:   ; @scripts/07-status.sh
cleanup:  ; @scripts/99-cleanup.sh
all: cluster access arc runners test
