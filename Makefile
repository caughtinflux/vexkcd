include theos/makefiles/common.mk
TARGET = iphone:clang
BUNDLE_NAME = vexkcd
vexkcd_FILES = VEXFolderView.mm
vexkcd_INSTALL_PATH = /Library/Velox/Plugins/
vexkcd_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
