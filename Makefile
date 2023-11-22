CFLAGS ?= -g -O2 -Wall
LDFLAGS ?= -lbsd
CC ?= cc
SRCS := $(wildcard *.c)
PROGS := $(patsubst %.c,%,$(SRCS))
ART ?= artefacts
FAST ?= false

%: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

.PHONY: all
all: $(PROGS)

test: all
	@mkdir -p $(ART)
ifeq ($(FAST),false)
	@echo Cracking open+write with tracepoint A... ; sleep 1
	@./run-race-openwrite.sh -a $(ART)/__noopenwrite
	@echo Cracking open+write with tracepoint B...; sleep 1
	@./run-race-openwrite.sh -b $(ART)/__noopenwrite
else
	@echo race-openwrite: skipped
endif
	@./run-pipewrite.sh || true
	@./run-chmod.sh $(ART)/__nochmod || true
	@./run-rename.sh $(ART)/__norename || true
	@./run-link.sh $(ART)/__nolink || true
	@./run-unlink.sh $(ART)/__nounlink || true
	@./run-truncate.sh $(ART)/__notruncate || true
	@./run-mknod.sh $(ART)/__nomknod || true
	@./run-onewrite.sh $(ART)/__onewrite || true
	@./run-taskalloc.sh || true
	@./run-exec.sh $(ART)/__noexec || true
