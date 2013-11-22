BUILD:=$(shell pwd)/build
PKG_CONFIG_PATH=$(BUILD)/lib/pkgconfig

all: SPDY


build/lib/libcrypto.a: OpenSSL-for-iPhone/build-libssl.sh
	cd OpenSSL-for-iPhone && INSTALL_DIR=$(BUILD) make all

openssl: build/lib/libcrypto.a


spdylay/configure: spdylay/configure.ac build/lib/libz.a build/lib/libcrypto.a
	cd spdylay && autoreconf -i && automake && autoconf
	touch spdylay/configure

build/armv7/lib/libspdylay.a: spdylay/configure ios-configure
	cd spdylay && ../ios-configure -p "$(BUILD)/armv7" -k $(PKG_CONFIG_PATH) iphone --with-xml-prefix=/unkonwn
	cd spdylay/lib && make install

build/armv7s/lib/libspdylay.a: spdylay/configure ios-configure
	cd spdylay && ../ios-configure -p "$(BUILD)/armv7s" -k $(PKG_CONFIG_PATH) iphone-armv7s  --with-xml-prefix=/unkonwn
	cd spdylay/lib && make install

build/i386/lib/libspdylay.a: spdylay/configure ios-configure
	cd spdylay && ../ios-configure -p "$(BUILD)/i386" -k $(PKG_CONFIG_PATH) simulator --with-xml-prefix=/unkonwn
	cd spdylay/lib && make install

#build/native/lib/libspdylay.a: spdylay/configure
#	cd spdylay && ./configure --prefix="$(BUILD)/native"
#	cd spdylay && make install


#build/lib/libspdylay.a: build/armv7s/lib/libspdylay.a build/armv7/lib/libspdylay.a build/i386/lib/libspdylay.a build/native/lib/libspdylay.a
build/lib/libspdylay.a: build/armv7s/lib/libspdylay.a build/armv7/lib/libspdylay.a build/i386/lib/libspdylay.a
	lipo -create "build/armv7s/lib/libspdylay.a" "build/armv7/lib/libspdylay.a" "build/i386/lib/libspdylay.a" -output "build/lib/libspdylay.a"
	cp -r build/armv7/include/* build/include

spdylay: build/lib/libspdylay.a


build/i386/lib/libz.a: zlib/build-zlib.sh
	cd zlib && PLATFORM=iPhoneSimulator ARCH=i386 ROOTDIR=$(BUILD)/i386 ./build-zlib.sh

#build/native/lib/libz.a: zlib/build-native-zlib.sh
#	cd zlib && ROOTDIR=$(BUILD)/native ./build-native-zlib.sh

build/armv7/lib/libz.a: zlib/build-zlib.sh
	cd zlib && PLATFORM=iPhoneOS ARCH=armv7 ROOTDIR=$(BUILD)/armv7 ./build-zlib.sh

build/armv7s/lib/libz.a: zlib/build-zlib.sh
	cd zlib && PLATFORM=iPhoneOS ARCH=armv7s ROOTDIR=$(BUILD)/armv7s ./build-zlib.sh

#build/lib/libz.a: build/i386/lib/libz.a build/armv7/lib/libz.a build/armv7s/lib/libz.a build/native/lib/libz.a
build/lib/libz.a: build/i386/lib/libz.a build/armv7/lib/libz.a build/armv7s/lib/libz.a
	-mkdir -p build/lib/pkgconfig
#	lipo -create build/armv7s/lib/libz.a build/armv7/lib/libz.a build/i386/lib/libz.a -output build/lib/libz.a build/native/lib/libz.a
	lipo -create build/armv7s/lib/libz.a build/armv7/lib/libz.a build/i386/lib/libz.a -output build/lib/libz.a
	sed -e 's,prefix=\(.*\)/armv7,prefix=\1,g' build/armv7/lib/pkgconfig/zlib.pc > build/lib/pkgconfig/zlib.pc

zlib: build/lib/libz.a


build/lib/libSPDY.a: build/lib/libspdylay.a
	cd SPDY && make

SPDY: build/lib/libSPDY.a


clean:
	-rm -r build

update-spdylay:
	cd spdylay && git pull
	-rm build/lib/libspdylay.* build/{armv7s,armv7,i386}/lib/libspdylay.*


check: SPDY
	cd SPDY && make check


.PHONY: all check spdylay zlib openssl SPDY clean update-spdylay
