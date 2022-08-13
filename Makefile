NAME            := catppuccin-f35
VERSION         := 0.1.1
ROOT_DIR        := $(shell pwd)
PACKER_BIN      := /usr/bin/packer
PACKER_TEMPLATE := $(ROOT_DIR)/template.pkr.hcl
PACKER_ARGS     := ""
ifndef CI
PACKER_ARGS     += "-color=false -on-error=abort"
endif
VBOX_OUTPUT     := $(ROOT_DIR)/output-vbox/package.box
QEMU_OUTPUT     := $(ROOT_DIR)/output-qemu/package.box

ORANGE = \e[0;33m
GREEN = \e[0;32m
END = \e[0m

.PHONY: vbox qemu all clean check-token upload-vbox upload-qemu help

define help_text
Targets:
  - make vbox:           Create VirtualBox target.
  - make qemu:           Create QEMU/Libvirt target.
  - make all:            Create all targets listed above.
  - make upload-vbox:    Upload to Vagrant Cloud.
  - make upload-qemu:    Upload to Vagrant Cloud.
  - make clean:          Delete everything, including the built boxes.
  - make [help]:         Print this help.
endef
export help_text

help:
	@echo "$$help_text"

all: vbox qemu
	@echo -e "${GREEN}Build is complete!${END}"

# Try to include a .env file (that has secrets) but don't fail if it's not there
-include .env

vbox: $(VBOX_OUTPUT)
qemu: $(QEMU_OUTPUT)

$(VBOX_OUTPUT): $(PACKER_TEMPLATE)
	@echo -e "${GREEN}Starting build for vbox!${END}"
	$(PACKER_BIN) build -force -only=vagrant.vbox $(PACKER_ARGS) $(PACKER_TEMPLATE)

$(QEMU_OUTPUT): $(PACKER_TEMPLATE)
	@echo -e "${GREEN}Starting build for qemu!${END}"
	$(PACKER_BIN) build -force -only=vagrant.qemu $(PACKER_ARGS) $(PACKER_TEMPLATE)

export ATLAS_TOKEN=$(VAGRANT_CLOUD_TOKEN)
upload-vbox: check-token $(VBOX_OUTPUT)
	@vagrant cloud publish braheezy/$(NAME) \
		$(VERSION) \
		virtualbox \
		$(VBOX_OUTPUT) \
		--release \
		--force
# Using --description flag in 'cloud publish' doesn't seem to work...
	@vagrant cloud version update braheezy/$(NAME) $(VERSION) \
		--description "Demo of various Catppuccin ports. Homepage: https://github.com/braheezy/prettybox-catppuccin"
upload-qemu: check-token $(QEMU_OUTPUT)
	@vagrant cloud publish braheezy/$(NAME) \
		$(VERSION) \
		libvirt \
		$(QEMU_OUTPUT) \
		--release \
		--force
# Using --description flag in 'cloud publish' doesn't seem to work...
	@vagrant cloud version update braheezy/$(NAME) $(VERSION) \
		--description "Demo of various Catppuccin ports. Homepage: https://github.com/braheezy/prettybox-catppuccin"

# If access token isn't avaiable, don't run upload
check-token:
ifndef VAGRANT_CLOUD_TOKEN
	$(error VAGRANT_CLOUD_TOKEN is undefined, needed for upload)
endif

clean:
	@echo -e "${GREEN}Deleting output folders...${END}"
	@rm -rf output-*
