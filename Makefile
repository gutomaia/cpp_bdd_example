PYTHON_MAJOR=3
PYTHON_MINOR=5
PYTHON_VERSION=${PYTHON_MAJOR}.${PYTHON_MINOR}

PY_BIND11_DEB=pybind11-dev_2.0.1-4_all.deb
PY_BIND11_DEB_URL=http://archive.ubuntu.com/ubuntu/pool/universe/p/pybind11/${PY_BIND11_DEB}

VIRTUALENV_DIR=$(CURDIR)/venv
VIRTUALENV_ARGS=-p /usr/bin/python3.5
VIRTUALENV_CMD=${VIRTUALENV_DIR}/bin/activate
VIRTUALENV=. ${VIRTUALENV_CMD};

CHECKPOINT_DIR=.checkpoint
CHECKPOINT=${CHECKPOINT_DIR}/.check

EXTENSION=${shell python${PYTHON_MAJOR}-config --extension-suffix}

ifeq "3" "$PYTHON_MAJOR"
PYTHON_LIB=python${PYTHON_VERSION}m
else
PYTHON_LIB=python${PYTHON_VERSION}
endif

INCLUDE = -I/usr/include/python${PYTHON_VERSION}m
LIBDIR  = -L/usr/lib/python${PYTHON_VERSION}

OUTPUT=example${EXTENSION}

FLAGS = -Wall -std=c++11 -O3 -fPIC
CC = g++
CFLAGS = $(FLAGS) $(INCLUDE)
LIBS = -lpython${PYTHON_VERSION}m

default: test

${OUTPUT}: py_example.c example.c
	$(CC) $(CFLAGS) --shared -o $@ $(LIBDIR) $< $(LIBS)

${VIRTUALENV_CMD}:
	@test -d ${VIRTUALENV_DIR} || virtualenv ${VIRTUALENV_ARGS} ${VIRTUALENV_DIR} > /dev/null && touch $@

${CHECKPOINT}:
	@mkdir -p ${CHECKPOINT_DIR} && touch $@

${CHECKPOINT_DIR}/upgrade_pip: ${CHECKPOINT} ${VIRTUALENV_CMD}
	@${VIRTUALENV} pip install --upgrade pip && touch $@

${CHECKPOINT_DIR}/requirements.txt: requirements.txt ${CHECKPOINT_DIR}/upgrade_pip
	@${VIRTUALENV} pip install -r requirements.txt && touch $@

${VIRTUALENV_DIR}/lib/python${PYTHON_VERSION}/${OUTPUT}: ${OUTPUT} ${CHECKPOINT_DIR}/requirements.txt
	cp $< $@

test: ${VIRTUALENV_DIR}/lib/python${PYTHON_VERSION}/${OUTPUT}
	@${VIRTUALENV} cd test/behave && behave

clean:
	rm ${OUTPUT}

purge: clean
	rm -rf ${VIRTUALENV_DIR}

.PHONY: test
