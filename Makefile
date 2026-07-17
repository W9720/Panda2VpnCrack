 THEOS_DEVICE_IP = 127.0.0.1
 THEOS_DEVICE_PORT = 2222
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Panda2VpnCrack

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
$(TWEAK_NAME)_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Panda2Vpn"
