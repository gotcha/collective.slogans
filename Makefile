#!/usr/bin/make
#
pybot_options =

.PHONY: instance cleanall test robot stop

PACKAGE_ROOT = src/collective/slogans

GS_FILES = $(PACKAGE_ROOT)/profiles/*/*.xml 

BUILDOUT_COMMAND = ./bin/buildout -Nt 5

all: instance

ifneq ($(strip $(TRAVIS)),)
IS_TRAVIS = yes
endif

ifdef IS_TRAVIS

# use cache to accelerate download 
download-and-eggs-plone-4.1.4.tgz:
	wget https://github.com/downloads/plone/Products.CMFPlone/download-and-eggs-plone-4.1.4.tgz
 
download-cache: download-and-eggs-plone-4.1.4.tgz
	tar -xzf download-and-eggs-plone-4.1.4.tgz
	touch $@

# use specific buildout that depends on cache
buildout.cfg: travis.cfg
	cp travis.cfg buildout.cfg

BUILDOUT_FILES = buildout.cfg setup.py bin/buildout download-cache

# use python as Travis has setup the virtualenv
bin/buildout: bootstrap.py buildout.cfg
	python bootstrap.py
	touch $@

else

# make a virtualenv
bin/python:
	virtualenv-2.6 --no-site-packages .
	touch $@

buildout.cfg: dev.cfg
	cp dev.cfg buildout.cfg

BUILDOUT_FILES = buildout.cfg setup.py bin/buildout

bin/buildout: bin/python bootstrap.py buildout.cfg
	./bin/python bootstrap.py
	touch $@

endif

bin/test: $(BUILDOUT_FILES)
	$(BUILDOUT_COMMAND) install test
	touch $@

parts/instance: $(BUILDOUT_FILES)
	$(BUILDOUT_COMMAND) install instance
	touch $@

bin/instance: parts/instance
	if [ -f var/plonesite ]; then rm var/plonesite; fi
	touch $@
	
var/plonesite: $(GS_FILES) bin/instance
	$(BUILDOUT_COMMAND) install plonesite
	touch $@

instance: var/plonesite
	bin/instance fg

cleanall:
	if [ -f var/supervisord.pid ]; then bin/supervisorctl shutdown; sleep 5; fi
	rm -fr bin develop-eggs downloads eggs parts .installed.cfg

test: bin/test	
	./bin/test

bin/pybot: $(BUILDOUT_FILES)
	$(BUILDOUT_COMMAND) install robot
	touch $@

bin/supervisord: $(BUILDOUT_FILES)
	$(BUILDOUT_COMMAND) install varnish-build varnish-conf varnish supervisor
	touch $@

bin/supervisorctl: bin/supervisord
	touch $@

var/supervisord.pid: bin/supervisord bin/supervisorctl
	if [ -f var/supervisord.pid ]; then bin/supervisorctl shutdown; sleep 5; fi
	bin/supervisord --pidfile=$@

robot: bin/pybot var/supervisord.pid
	bin/pybot $(pybot_options) -d robot-output acceptance-tests 

stop: 
	bin/supervisorctl shutdown

