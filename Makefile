#!/usr/bin/make
#
options =

.PHONY: instance cleanall test robot

PACKAGE_ROOT = src/collective/slogans

GS_FILES = $(PACKAGE_ROOT)/profiles/*/*.xml 

BUILDOUT_FILES = buildout.cfg setup.py bin/buildout

PYBOT_BUILDOUT_FILES = $(BUILDOUT_FILES) pybot.cfg

DATA_FS = var/filestorage/Data.fs

all: instance

ifneq ($(strip $(TRAVIS_PYTHON_VERSION)),)
IS_TRAVIS = yes
endif

ifdef IS_TRAVIS
develop-eggs: bootstrap.py buildout.cfg
	python bootstrap.py

PYBOT_BINARY = pybot

$(PYBOT_BINARY):
	echo "noop" 
else
bin/python:
	virtualenv-2.6 --no-site-packages .

develop-eggs: bin/python bootstrap.py buildout.cfg
	./bin/python bootstrap.py

bin/pip: bin/python
	touch $@

PYBOT_BINARY = bin/pybot

$(PYBOT_BINARY): bin/pip
	bin/pip install robotframework==2.7.1
	bin/pip install --extra-index-url http://packages.affinitic.be robotframework-selenium2library==1.0.0.2
endif

buildout.cfg:
	ln -s dev.cfg buildout.cfg

bin/buildout: develop-eggs

bin/test: $(BUILDOUT_FILES)
	./bin/buildout -Nvt 5 install test
	touch $@

bin/instance: $(BUILDOUT_FILES)
	./bin/buildout -Nvt 5 install instance
	touch $@
	
$(DATA_FS): $(GS_FILES)	bin/instance
	if [ -f var/supervisord.pid ]; then bin/supervisorctl shutdown; sleep 5; fi
	./bin/buildout -Nvt 5 install plonesite

instance: bin/instance $(DATA_FS)
	bin/instance fg

cleanall:
	rm -fr bin develop-eggs downloads eggs parts .installed.cfg

test: bin/test	
	./bin/test

bin/supervisord: $(PYBOT_BUILDOUT_FILES)
	./bin/buildout -Nvt 5 -c pybot.cfg install supervisor
	touch $@

bin/supervisorctl: bin/supervisord
	touch $@

var/supervisord.pid: bin/supervisord bin/instance bin/supervisorctl
	if [ -f var/supervisord.pid ]; then bin/supervisorctl shutdown; sleep 5; fi
	bin/supervisord --pidfile=$@
	bin/supervisorctl start all
	touch $@

robot: $(PYBOT_BINARY) var/supervisord.pid
	$(PYBOT_BINARY) $(options) -d robot-output acceptance-tests
