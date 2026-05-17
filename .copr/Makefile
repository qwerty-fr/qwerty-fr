THISDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
RPMDIR := $(THISDIR)/../linux/rpm

.PHONY: srpm

srpm:
	$(MAKE) -C $(RPMDIR) -f Makefile srpm \
		SRCRPMDIR="$(outdir)"
