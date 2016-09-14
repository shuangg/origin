DEBUG ?= 1
ifeq ($(DEBUG), 1)
    CFLAGS=-O0 -g
else
    CFLAGS=-O3 -Wno-disabled-macro-expansion
endif
CC=clang
#CFLAGS=-std=c99 -pedantic-errors -Wall -Wextra -Wshadow -Wpointer-arith \
 -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes -I.
CFLAGS+=-std=c11 -D_GNU_SOURCE -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700 -Weverything -Werror -Wno-format-nonliteral 
# /usr/lib/libprofiler.so.0
LFLAGS=-lprofiler
OUT=target/origin
ODIR=target
SDIR=src
_OBJS=origin.o
OBJS=$(patsubst %,$(ODIR)/%,$(_OBJS))
PROFOUT=target/prof.out

compile: $(OUT)

all: analyze clean target check

target:
	mkdir target

$(OUT): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LFLAGS) 

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) -c -o $@ $< $(CFLAGS)

clean:
	rm -rf $(ODIR)/*

analyze: 
	scan-build --status-bugs --use-cc=clang make clean $(OUT)

check: $(OUT)
	./tests.py

$(PROFOUT): $(OUT)
	CPUPROFILE=$(PROFOUT) CPUPROFILE_REALTIME=1 ./target/origin ll

profile: $(PROFOUT)

view-profile: $(PROFOUT)
	google-pprof $(OUT) $(PROFOUT)
