.PHONY: default
default: build

ROOTDIR ?= $(abspath ..)
ARTIFACTS ?= $(ROOTDIR)/artifacts
SRC_DIR ?= $(ROOTDIR)
BUILDS_DIR ?= $(ROOTDIR)/build

$(SRC_DIR)/cpu/.git:
	git clone --depth 1 https://github.com/u-root/cpu.git $(SRC_DIR)/cpu

$(ARTIFACTS)/cpu: $(SRC_DIR)/cpu/.git
	cd $(SRC_DIR)/cpu && go build -o $(ARTIFACTS)/cpu $(SRC_DIR)/cpu/cmds/cpu/.

$(ARTIFACTS)/cpud: $(SRC_DIR)/cpu/.git
	cd $(SRC_DIR)/cpu && go build -o $(ARTIFACTS)/cpud $(SRC_DIR)/cpu/cmds/cpud/.

$(SRC_DIR)/u-root/.git:
	git clone --depth 1 https://github.com/u-root/u-root.git $(SRC_DIR)/u-root

$(BUILDS_DIR)/u-root/u-root: $(SRC_DIR)/u-root/.git
	mkdir -p $(BUILDS_DIR)/u-root
	cd $(SRC_DIR)/u-root && go mod tidy && go build -o $(BUILDS_DIR)/u-root

${HOME}/.ssh/identity:
	mkdir -p ${HOME}/.ssh
	ssh-keygen -N "" -f ${HOME}/.ssh/identity

$(ARTIFACTS)/identity.pub: ${HOME}/.ssh/identity
	cp ${HOME}/.ssh/identity.pub $(ARTIFACTS)

$(ARTIFACTS)/Image.guest: $(ARTIFACTS)
	wget -O $(ARTIFACTS)/Image.guest https://github.com/ericvh/cca-cpu/releases/latest/download/Image.guest > /dev/null 2>&1

$(SRC_DIR)/go.work: $(SRC_DIR)/cpu/.git $(SRC_DIR)/u-root/.git
	rm -f $(SRC_DIR)/go.work
	cd $(SRC_DIR) && go work init $(SRC_DIR)/u-root && go work use $(SRC_DIR)/cpu

$(ARTIFACTS):
	mkdir -p $(ARTIFACTS)

$(ARTIFACTS)/initramfs.cpio: $(SRC_DIR)/go.work ${HOME}/.ssh/identity $(BUILDS_DIR)/u-root/u-root $(ARTIFACTS)
	cd $(SRC_DIR) && $(BUILDS_DIR)/u-root/u-root -o $(ARTIFACTS)/initramfs.cpio \
	 -files ${HOME}/.ssh/identity.pub:key.pub \
	 -uinitcmd='/bbin/cpud -d'\
	 -files /mnt \
	 $(SRC_DIR)/cpu/cmds/cpud $(SRC_DIR)/cpu/cmds/cpu $(SRC_DIR)/u-root/cmds/core/{init,gosh,ls,mount}

.PHONY: build
build: $(ARTIFACTS)/initramfs.cpio $(ARTIFACTS)/cpu

.PHONY: cpu cpud
cpu: $(ARTIFACTS)/cpu
cpud: $(ARTIFACTS)/cpud $(ARTIFACTS)/identity.pub

.PHONY: initramfs.cpio
initramfs.cpio: $(ARTIFACTS)/initramfs.cpio

clean:
	rm -f $(BUILDS_DIR)/u-root-initramfs
	rm -rf $(BUILDS_DIR)/u-root
	rm -f $(SRC_DIR)/go.*

nuke: clean
	rm -rf $(SRC_DIR)/cpu
	rm -rf $(SRC_DIR)/u-root
	rm -rf $(SRC_DIR)/build
	rm -rf $(SRC_DIR)/artifacts
