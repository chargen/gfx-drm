#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2016 Gordon W. Ross
#

PROG= \
	openclose	\
	getversion	\
	getclient	\
	getstats	\
	setversion	\
	updatedraw	\
	name_from_fd	\
	getsundev

# All programs here require this devinfo object.
DEVOBJ=drmtest_sun.o

include	../../Makefile.drm

SRCDIR= $(LIBDRM_CMN_DIR)/tests

LDLIBS	 +=	-ldrm -lm -ldevinfo

LDLIBS32 +=	-L$(ROOT)/usr/lib/xorg \
		-R/usr/lib/xorg
LDLIBS64 +=	-L$(ROOT)/usr/lib/xorg/$(MACH64) \
		-R/usr/lib/xorg/$(MACH64)

all:	 $(PROG)

#This is in the lower Makefile
#install:	$(ROOTCMD)

lint:

clean:     
	$(RM) $(PROG:%=%.o) $(DEVOBJ)

% : $(SRCDIR)/%.c $(DEVOBJ)
	$(COMPILE.c) -o $@.o $<
	$(LINK.c) -o $@ $@.o $(DEVOBJ) $(LDLIBS)

%.o : ../common/%.c
	$(COMPILE.c) -o $@ -c $<

getsundev : getsundev.o
	$(LINK.c) -o $@ $@.o $(DEVOBJ) $(LDLIBS)

.KEEP_STATE:

include	../../../Makefile.targ
