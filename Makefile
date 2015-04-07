#############################################################################
#
# Makefile for RF24Mesh on Raspberry Pi
#
# Author:  TMRh20 
# Date:    2014/09 
#
# Description:
# ------------
# use make all and make install to install the library 
# You can change the install directory by editing the LIBDIR line
#
PREFIX=/usr/local

# Library parameters
# where to put the lib
LIBDIR=$(PREFIX)/lib
# lib name 
LIB_RFN=librf24gateway
# shared library name
LIBNAME_RFN=$(LIB_RFN).so.1.0

HEADER_DIR=${PREFIX}/include/RF24Gateway

# Detect the Raspberry Pi from cpuinfo
#Count the matches for BCM2708 or BCM2709 in cpuinfo
RPI=$(shell cat /proc/cpuinfo | grep Hardware | grep -c BCM2708)
ifneq "${RPI}" "1"
RPI=$(shell cat /proc/cpuinfo | grep Hardware | grep -c BCM2709)
endif

CCFLAGS=-std=c++0x

ifeq "$(RPI)" "1"
# The recommended compiler flags for the Raspberry Pi
CCFLAGS+=-Ofast -mfpu=vfp -mfloat-abi=hard -march=armv6zk -mtune=arm1176jzf-s 
endif

# make all
# reinstall the library after each recompilation
all: librf24gateway

# Make the library
librf24gateway: RF24Gateway.o
	g++ -shared -Wl,-soname,$@.so.1 ${CCFLAGS} -o ${LIBNAME_RFN} $^

# Library parts
RF24Gateway.o: RF24Gateway.cpp
	g++ -Wall -fPIC ${CCFLAGS} -c $^

# clear build files
clean:
	rm -rf *.o ${LIB_RFN}.*

install: all install-libs install-headers

# Install the library to LIBPATH

install-libs: 
	@echo "[Install]"
	@if ( test ! -d $(PREFIX)/lib ) ; then mkdir -p $(PREFIX)/lib ; fi
	@install -m 0755 ${LIBNAME_RFN} ${LIBDIR}
	@ln -sf ${LIBDIR}/${LIBNAME_RFN} ${LIBDIR}/${LIB_RFN}.so.1
	@ln -sf ${LIBDIR}/${LIBNAME_RFN} ${LIBDIR}/${LIB_RFN}.so
	@ldconfig

install-headers:
	@echo "[Installing Headers]"
	@if ( test ! -d ${HEADER_DIR} ) ; then mkdir -p ${HEADER_DIR} ; fi
	@install -m 0644 *.h ${HEADER_DIR}
