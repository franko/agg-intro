
AGG_LIBS= -L/c/fra/src/agg-2.5/src -lagg
AGG_INCLUDES= -I/c/fra/src/agg-2.5/include

CXXFLAGS= -g -Wall
LIBS= $(AGG_LIBS) -lsupc++
INCLUDES= $(AGG_INCLUDES)

all: test.exe

clean:
	rm test.exe main.o

test.exe: main.o
	gcc -o test.exe main.o $(LIBS)

%.o: %.cpp
	gcc $(CXXFLAGS) -c $< $(INCLUDES)

.PHONY: clean all

main.o: main.cpp
