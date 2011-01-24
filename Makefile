#  Copyright (c) 2011 Francesco Abbate
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

# AGG_LIBS= -L/c/fra/src/agg-2.5/src -lagg
# AGG_INCLUDES= -I/c/fra/src/agg-2.5/include

AGG_LIBS= -lagg
AGG_INCLUDES= -I/usr/include/agg2

CXXFLAGS= -g -Wall
LIBS= $(AGG_LIBS) -lm -lsupc++
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
