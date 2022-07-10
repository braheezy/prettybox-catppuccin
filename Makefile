NAME            := catppuccin-f35
VERSION         := 0.1.0
ROOT_DIR        := $(shell pwd)
PACKER_BIN      := /usr/bin/packer
PACKER_ARGS     := -force -var version=$(VERSION)
PACKER_TEMPLATE := $(ROOT_DIR)/template.pkr.hcl

ORANGE = \e[0;33m
GREEN = \e[0;32m
END = \e[0m

.PHONY: vbox qemu all clean clean_all help

define help_text
Targets:
  - make vbox:      Create VirtualBox target.
  - make qemu:      Create QEMU/Libvirt target.
  - make all:       Create all targets listed above.
  - make clean:     Delete everything, including the built boxes.
  - make [help]:    Print this help.
endef
export help_text

help:
	@echo "$$help_text"

all: vbox qemu
	@echo -e "${GREEN}Build is complete!${END}"

# Try to include a .env file (that has secrets) but don't fail if it's not there
-include .env

# If access token isn't avaiable, don't run vagrant cloud post-processor in Packer
ifndef VAGRANT_CLOUD_TOKEN
    PACKER_ARGS += --except="vagrant-cloud"
endif

export VAGRANT_CLOUD_TOKEN
vbox qemu: $(PACKER_TEMPLATE)
	@echo -e "${GREEN}Starting build for $@!${END}"
	$(PACKER_BIN) build $(PACKER_ARGS) -only=vagrant.$@ $(PACKER_TEMPLATE)

clean:
	@echo -e "${GREEN}Deleting output folders...${END}"
	@rm -rf output-*
