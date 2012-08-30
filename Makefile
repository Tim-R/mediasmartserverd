SHELL = /bin/bash

# compiler and flags
CC = gcc
CXX = g++
FLAGS = -Wall -O2
CFLAGS = $(FLAGS)
CXXFLAGS = $(CFLAGS)
LDFLAGS = -ludev

LIBUDEV := $(shell if ( [ "`lsb_release -is`" == "Ubuntu" ] && [ "`lsb_release -cs`" != "lucid" ] ); then echo "`uname -i`-linux-gnu/"; else echo ""; fi)

# build libraries and options
all: clean mediasmartserverd

clean:
	rm *.o mediasmartserverd core -f

device_monitor.o: src/device_monitor.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $^

mediasmartserverd.o: src/mediasmartserverd.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $^

mediasmartserverd: device_monitor.o mediasmartserverd.o /usr/lib/$(LIBUDEV)libudev.so
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $^

prepare-for-packaging:
	@if [ "$(PACKAGE_VERSION)" != "" ]; then \
		cd ..; \
		mkdir mediasmartserver; \
		cp -RLv mediasmartserverd/{LICENSE,Makefile,readme.txt,README.md,src,package/*} mediasmartserver; \
		tar cfz mediasmartserver-$(PACKAGE_VERSION).tar.gz mediasmartserver; \
		rm -rf mediasmartserver; \
		bzr dh-make mediasmartserver $(PACKAGE_VERSION) mediasmartserver-$(PACKAGE_VERSION).tar.gz; \
		rm -rf mediasmartserver/debian/{*.ex,*.EX,README.Debian,README.source}; \
	fi

package-unsigned:
	bzr builddeb -- -us -uc

package-signed:
	bzr builddeb -S

