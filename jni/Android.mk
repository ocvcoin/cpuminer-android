LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)



# Begin libocv2
LOCAL_MODULE    := ocv2
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libocv2.so

include $(PREBUILT_SHARED_LIBRARY)
include $(CLEAR_VARS)



# Begin libcurl
LOCAL_MODULE    := curl
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libcurl.so

include $(PREBUILT_SHARED_LIBRARY)
include $(CLEAR_VARS)




# Begin libocv2-neon
ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	
	LOCAL_MODULE    := ocv2-neon
	LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libocv2-neon.so

	include $(PREBUILT_SHARED_LIBRARY)
	include $(CLEAR_VARS)
endif



# Begin ocvminer
LOCAL_DISABLE_FATAL_LINKER_WARNINGS=true


ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/arm/include"
endif

ifeq ($(TARGET_ARCH_ABI),x86)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/x86/include"
endif

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/arm64/include"
endif

ifeq ($(TARGET_ARCH_ABI),x86_64)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/x86_64/include"
endif



LOCAL_C_INCLUDES += $(LOCAL_PATH)/../include/
LOCAL_SRC_FILES := \
 cpu-miner.c \
 native.c \
 util.c \
 sha2.c \
 sha2-arm.S \
 sha2-x64.S \
 sha2-x86.S \
 scrypt.c \
 scrypt-arm.S \
 scrypt-x64.S \
 scrypt-x86.S \
 dump.c \
 hashtable.c \
 load.c \
 strbuffer.c \
 utf.c \
 value.c \
 ocv2.c \

ifeq ($(TARGET_ARCH_ABI),$(filter $(TARGET_ARCH_ABI),armeabi armeabi-v7a arm64-v8a))
	LOCAL_ARM_MODE := arm
	LOCAL_ARM_NEON := false
endif

LOCAL_SHARED_LIBRARIES := curl ocv2
LOCAL_CFLAGS := -O3
LOCAL_LDLIBS := -lm -llog -ldl

LOCAL_MODULE    := ocvminer

include $(BUILD_SHARED_LIBRARY)
include $(CLEAR_VARS)

# Begin ocvminer-neon (armeabi-v7a only)


ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/arm/include"
endif

ifeq ($(TARGET_ARCH_ABI),x86)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/x86/include"
endif

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/arm64/include"
endif

ifeq ($(TARGET_ARCH_ABI),x86_64)
	LOCAL_C_INCLUDES += "/opt/android-ndk-r11c/x86_64/include"
endif


LOCAL_C_INCLUDES += $(LOCAL_PATH)/../include/
LOCAL_SRC_FILES := \
 cpu-miner.c \
 native.c \
 util.c \
 sha2.c \
 sha2-arm.S \
 sha2-x64.S \
 sha2-x86.S \
 scrypt.c \
 scrypt-arm.S \
 scrypt-x64.S \
 scrypt-x86.S \
 dump.c \
 hashtable.c \
 load.c \
 strbuffer.c \
 utf.c \
 value.c \
 ocv2.c \

LOCAL_ARM_MODE := arm
LOCAL_ARM_NEON := true
LOCAL_CFLAGS := -O3 -D__NEON__

LOCAL_SHARED_LIBRARIES := curl ocv2-neon
LOCAL_LDLIBS := -lm -llog -ldl

LOCAL_MODULE    := ocvminer-neon

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
	include $(BUILD_SHARED_LIBRARY)
endif
include $(CLEAR_VARS)

# Begin neondetect
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../include/
LOCAL_SRC_FILES := neon_detect.c

LOCAL_STATIC_LIBRARIES := cpufeatures
LOCAL_CFLAGS := -O3
LOCAL_LDLIBS := -llog -ldl

LOCAL_MODULE    := neondetect

include $(BUILD_SHARED_LIBRARY)

$(call import-module,android/cpufeatures)