# Makefile for building and installing various Linux components
# Portable between projects
# Don't put code about git branches in here, it's just messy

# Rules assume that you're working with the SPL configuration of uBoot
ARCH=sc589
BOARD=mini

TOPDIR=`pwd`
UBOOT_DIR=$(TOPDIR)/u-boot
LINUX_DIR=$(TOPDIR)/linux-kernel
BUILDROOT_DIR=$(TOPDIR)/buildroot
FASTBOOT_DIR=$(TOPDIR)/fastboot-listener
TFTP_DIR=/tftpboot
BRANCH=develop/linuxaddin-1.3.1-fastboot
UBOOT_BRANCH=$(BRANCH)
LINUX_BRANCH=$(BRANCH)
BUILDROOT_BRANCH=$(BRANCH)
FASTBOOT_BRANCH=$(BRANCH)

# update sources, don't change branch
update_repo_%:
	cd $(UPDATE_DIR) && git pull && git status

update_uboot: UPDATE_DIR=$(UBOOT_DIR)
update_uboot: update_repo_uboot

update_linux: UPDATE_DIR=$(LINUX_DIR)
update_linux: update_repo_linux

update_buildroot: UPDATE_DIR=$(BUILDROOT_DIR)
update_buildroot: update_repo_buildroot

update_fastboot: UPDATE_DIR=$(FASTBOOT_DIR)
update_fastboot: update_repo_fastboot

update_all: update_uboot update_linux update_buildroot update_fastboot

# change branch, assume there's a local copy already
checkout_branch_%:
	cd $(CHECKOUT_DIR) && git checkout $(CHECKOUT_BRANCH)

branch_uboot: CHECKOUT_BRANCH=$(UBOOT_BRANCH)
branch_uboot: CHECKOUT_DIR=$(UBOOT_DIR)
branch_uboot: checkout_branch_uboot

branch_buildroot: CHECKOUT_BRANCH=$(BUILDROOT_BRANCH)
branch_buildroot: CHECKOUT_DIR=$(BUILDROOT_DIR)
branch_buildroot: checkout_branch_buildroot

branch_linux: CHECKOUT_BRANCH=$(LINUX_BRANCH)
branch_linux: CHECKOUT_DIR=$(LINUX_DIR)
branch_linux: checkout_branch_linux

branch_fastboot: CHECKOUT_BRANCH=$(FASTBOOT_BRANCH)
branch_fastboot: CHECKOUT_DIR=$(FASTBOOT_DIR)
branch_fastboot: checkout_branch_fastboot

branch_all: branch_uboot branch_buildroot branch_linux branch_fastboot

# Client build
build_client:
	cd $(FASTBOOT_DIR) && make client

# Install the fastboot listener into the skeleton directo
install_fastboot: build_fastboot
	cp $(FASTBOOT_DIR)/fastboot-listener $(BUILDROOT_DIR)/board/AnalogDevices/arm/target_skeleton/bin/fastboot-listener
	cp $(FASTBOOT_DIR)/fastboot-listener $(BUILDROOT_DIR)/output/target/bin/fastboot-listener

build_fastboot:
	cd $(FASTBOOT_DIR) && make fastboot-listener

install_uboot: build_uboot
	cp $(UBOOT_DIR)/u-boot-spl.ldr $(TFTP_DIR)/u-boot-$(ARCH)-$(BOARD)-spl.ldr
	cp $(UBOOT_DIR)/u-boot.bin $(TFTP_DIR)/u-boot-$(ARCH)-$(BOARD).bin

# The SPL Build reports errors about undefined symbols when calling the arm-none-eabi-ldr
# We need to ignore these errors for now
build_uboot:
	cd $(UBOOT_DIR) && make -i


install_linux: build_linux
	cp $(BUILDROOT_DIR)/output/images/uImage $(TFTP_DIR)/uImage-$(ARCH)-$(BOARD)
	cp $(BUILDROOT_DIR)/output/images/$(ARCH)-$(BOARD).dtb $(TFTP_DIR)/$(ARCH)-$(BOARD).dtb

build_linux:
	cd $(BUILDROOT_DIR) && make

clean_fastboot:
	cd $(FASTBOOT_DIR) && make clean

clean_uboot:
	cd $(UBOOT_DIR) && make clean

config_uboot:
	cd $(UBOOT_DIR) && make $(ARCH)-$(BOARD)_defconfig

clean_linux:
	cd $(BUILDROOT_DIR) && make clean

config_linux:
	cd $(BUILDROOT_DIR) && make $(ARCH)-$(BOARD)_defconfig

clean_all: clean_fastboot clean_uboot clean_linux