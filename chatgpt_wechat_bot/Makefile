THEOS_DEVICE_IP=192.168.1.227

TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = WeChat


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = wechatgpt

wechatgpt_FILES = Tweak.xm
wechatgpt_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
