#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit TWRP common config.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from yxp_713_pad device
$(call inherit-product, device/youxuepai/yxp_713_pad/device.mk)

PRODUCT_DEVICE := yxp_713_pad
PRODUCT_NAME := twrp_yxp_713_pad
PRODUCT_BRAND := YOUXUEPAI
PRODUCT_MODEL := U90
PRODUCT_MANUFACTURER := youxuepai

PRODUCT_GMS_CLIENTID_BASE := android-youxuepai

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="full_yxp_713_pad-userdebug 10 QP1A.190711.020 mp1V9262 release-keys"

BUILD_FINGERPRINT := YOUXUEPAI/full_yxp_713_pad/yxp_713_pad:10/QP1A.190711.020/mp1k61v164bspP3:userdebug/release-keys
