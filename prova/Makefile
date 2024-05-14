SOURCES := $(wildcard *.l)
TARGETS := $(patsubst %.l,%,$(SOURCES))

all: $(TARGETS)

$(TARGETS): % : %.l
	lex $<
	gcc -Wall lex.yy.c -ll -o $@ 

clean:
	rm -f *~ lex.yy.c $(TARGETS)