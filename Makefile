#
# Copyright (C) 2007-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=samba
PKG_VERSION:=3.6.24
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://ftp.samba.org/pub/samba \
	http://ftp.samba.org/pub/samba/stable
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MD5SUM:=d98425c0c2b73e08f048d31ffc727fb0

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Felix Fietkau <nbd@openwrt.org>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_PATH:=source3
CONFIGURE_PATH:=source3

PKG_BUILD_BIN:=$(PKG_BUILD_DIR)/$(MAKE_PATH)/bin

define Package/samba36-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Samba 3.6 SMB/CIFS server
  URL:=http://www.samba.org/
  DEPENDS:=+USE_EGLIBC:librt
endef

define Package/samba36-client
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Samba 3.6 SMB/CIFS client
  URL:=http://www.samba.org/
  DEPENDS:=+libreadline +libncurses
endef

define Package/samba36-server/config
	config PACKAGE_SAMBA_MAX_DEBUG_LEVEL
		int "Maximum level of compiled-in debug messages"
		depends on PACKAGE_samba36-server || PACKAGE_samba36-client
		default -1

endef

define Package/samba36-server/description
 The Samba software suite is a collection of programs that implements the
 SMB protocol for UNIX systems, allowing you to serve files and printers to
 Windows, NT, OS/2 and DOS clients. This protocol is sometimes also referred
 to as the LanManager or Netbios protocol.
endef

TARGET_CFLAGS += -DMAX_DEBUG_LEVEL=$(CONFIG_PACKAGE_SAMBA_MAX_DEBUG_LEVEL) -D__location__=\\\"\\\" -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_VARS += \
	ac_cv_lib_attr_getxattr=no \
	ac_cv_search_getxattr=no \
	ac_cv_file__proc_sys_kernel_core_pattern=yes \
	libreplace_cv_HAVE_C99_VSNPRINTF=yes \
	libreplace_cv_HAVE_GETADDRINFO=yes \
	libreplace_cv_HAVE_IFACE_IFCONF=yes \
	LINUX_LFS_SUPPORT=yes \
	samba_cv_CC_NEGATIVE_ENUM_VALUES=yes \
	samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
	samba_cv_HAVE_IFACE_IFCONF=yes \
	samba_cv_HAVE_KERNEL_OPLOCKS_LINUX=yes \
	samba_cv_HAVE_SECURE_MKSTEMP=yes \
	samba_cv_HAVE_WRFILE_KEYTAB=no \
	samba_cv_USE_SETREUID=yes \
	samba_cv_USE_SETRESUID=yes \
	samba_cv_have_setreuid=yes \
	samba_cv_have_setresuid=yes \
	ac_cv_header_zlib_h=no \
	samba_cv_zlib_1_2_3=no

CONFIGURE_ARGS += \
	--exec-prefix=/usr \
	--prefix=/ \
	--disable-avahi \
	--disable-cups \
	--disable-pie \
	--disable-relro \
	--disable-static \
	--disable-swat \
	--disable-shared-libs \
	--with-codepagedir=/etc/samba \
	--with-configdir=/etc/samba \
	--with-included-iniparser \
	--with-included-popt \
	--with-lockdir=/var/lock \
	--with-logfilebase=/var/log \
	--with-nmbdsocketdir=/var/nmbd \
	--with-piddir=/var/run \
	--with-privatedir=/etc/samba \
	--with-sendfile-support \
	--without-acl-support \
	--without-cluster-support \
	--without-ads \
	--without-krb5 \
	--without-ldap \
	--without-pam \
	--without-winbind \
	--without-libtdb \
	--without-libtalloc \
	--without-libnetapi \
	--without-libsmbclient \
	--without-libsmbsharemodes \
	--without-libtevent \
	--without-libaddns \
	--with-shared-modules=pdb_tdbsam,pdb_wbc_sam,idmap_nss,nss_info_template,auth_winbind,auth_wbc,auth_domain

MAKE_FLAGS += DYNEXP= PICFLAG= MODULES=

define Package/samba36-server/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/samba.config $(1)/etc/config/samba
	$(INSTALL_DIR) $(1)/etc/samba
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/samba
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/codepages/lowcase.dat $(1)/etc/samba
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/codepages/upcase.dat $(1)/etc/samba
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/codepages/valid.dat $(1)/etc/samba
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/samba.init $(1)/etc/init.d/samba
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_BIN)/samba_multicall $(1)/usr/sbin
	ln -sf samba_multicall $(1)/usr/sbin/smbd
	ln -sf samba_multicall $(1)/usr/sbin/nmbd
	ln -sf samba_multicall $(1)/usr/sbin/smbpasswd
endef

define Package/samba36-client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_BIN)/smbclient $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_BIN)/nmblookup $(1)/usr/sbin
endef

$(eval $(call BuildPackage,samba36-client))
$(eval $(call BuildPackage,samba36-server))

