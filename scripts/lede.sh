#!/bin/bash

# Add luci-app-ssr-plus
pushd package/lean
git clone --depth=1 https://github.com/fw876/helloworld
popd

# Add luci-app-vssr <M>
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 https://github.com/jerrykuku/luci-app-vssr


# Add luci-app-dockerman
# rm -rf ../lean/luci-app-docker
# git clone --depth=1 https://github.com/lisaac/luci-app-dockerman
# git clone --depth=1 https://github.com/lisaac/luci-lib-docker

# Add luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
rm -rf ../lean/luci-theme-argon


# 动态DNS
git clone --depth 1 https://github.com/small-5/ddns-scripts-dnspod package/lean/ddns-scripts_dnspod
git clone --depth 1 https://github.com/small-5/ddns-scripts-aliyun package/lean/ddns-scripts_aliyun
svn co https://github.com/QiuSimons/OpenWrt_luci-app/trunk/luci-app-tencentddns package/lean/luci-app-tencentddns
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-aliddns feeds/luci/applications/luci-app-aliddns
ln -sf ../../../feeds/luci/applications/luci-app-aliddns ./package/feeds/luci/luci-app-aliddns


# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
sed -i '/18.06/d' zzz-default-settings
export orig_version=$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
export date_version=$(date -d "$(rdate -n -4 -p ntp.aliyun.com)" +'%Y-%m-%d')
sed -i "s/${orig_version}/${orig_version} (${date_version})/g" zzz-default-settings
popd

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
svn co https://github.com/openwrt/packages/trunk/libs/libssh
popd

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='FusionWrt'' package/lean/default-settings/files/zzz-default-settings
sed -i "s/OpenWrt /DHDAXCW @ FusionWrt $(TZ=UTC-8 date "+%Y%m%d") /g" package/lean/default-settings/files/zzz-default-settings
# find package/*/ feeds/*/ -maxdepth 6 -path "*luci-app-smartdns/luasrc/controller/smartdns.lua" | xargs -i sed -i 's/\"SmartDNS\")\, 4/\"SmartDNS\")\, 3/g' {} 
# Test kernel 5.10
# sed -i 's/5.4/5.10/g' target/linux/rockchip/Makefile

# Custom configs
# git am $GITHUB_WORKSPACE/patches/lean/*.patch
git am $GITHUB_WORKSPACE/patches/*.patch
echo -e " DHDAXCW's FusionWrt built on "$(date +%Y.%m.%d)"\n -----------------------------------------------------" >> package/base-files/files/etc/banner
echo 'net.bridge.bridge-nf-call-iptables=0' >> package/base-files/files/etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables=0' >> package/base-files/files/etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-arptables=0' >> package/base-files/files/etc/sysctl.conf
echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' >> package/base-files/files/etc/sysctl.conf

# Add luci-app-adguardhome
# rm -rf package/lean/luci-app-adguardhome
# svn co https://github.com/Lienol/openwrt/trunk/package/diy/luci-app-adguardhome package/lean/luci-app-adguardhome
# rm -rf ./feeds/packages/net/adguardhome
# svn co https://github.com/openwrt/packages/trunk/net/adguardhome feeds/packages/net/adguardhome
# sed -i '/\t)/a\\t$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/AdGuardHome' ./feeds/packages/net/adguardhome/Makefile
# sed -i '/init/d' feeds/packages/net/adguardhome/Makefile
