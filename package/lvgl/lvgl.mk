################################################################################
#
# lvgl 
#
################################################################################

LVGL_VERSION = $(call qstrip,$(BR2_LVGL_VERSION))
LVGL_SITE = $(call github,lvgl,lvgl,v$(LVGL_VERSION))
LVGL_SOURCE = lvgl-$(LVGL_VERSION).tar.gz
LVGL_INSTALL_STAGING = YES
LVGL_LICENSE = MIT
LVGL_LICENSE_FILES = LICENCE.txt

LVGL_DEPENDENCIES = host-cmake

ifeq ($(BR2_LVGL_WAYLAND_BACKEND),y)
LVGL_DEPENDENCIES += wayland wayland-protocols
endif

LVGL_COLOR_DEPTH = $(call qstrip,$(BR2_LVGL_COLOR_DEPTH))

LVGL_DISPLAY_BACKEND = $(call qstrip,$(BR2_LVGL_DISPLAY_BACKEND))

ifeq ($(BR2_WESTON_VERSION_9_0_0)$(BR2_LVGL_VERSION_9_3_0),yy)
define LVGL_APPLY_PATCHES_FOR_WESTON_9_0_0
	$(APPLY_PATCHES) $(@D) $(LVGL_PKGDIR)/patches/9.3.0 *.patch
endef

LVGL_POST_PATCH_HOOKS += LVGL_APPLY_PATCHES_FOR_WESTON_9_0_0
endif

define GENERATE_WAYLAND_PROTOCOLS_CLIENT_FILES
	$(call MESSAGE,"Generating wayland client protocols files") && \
	$(HOST_DIR)/bin/wayland-scanner private-code \
	$(STAGING_DIR)/usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml \
	$(@D)/src/drivers/wayland/xdg-shell-protocol.c && \
	\
	$(HOST_DIR)/bin/wayland-scanner client-header \
	$(STAGING_DIR)/usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml \
	$(@D)/src/drivers/wayland/wayland_xdg_shell.h
endef
ifeq ($(BR2_LVGL_WAYLAND_BACKEND),y)
LVGL_PRE_CONFIGURE_HOOKS += GENERATE_WAYLAND_PROTOCOLS_CLIENT_FILES
endif

define CONFIGURE_COLOR_DEPTH
	@$(call MESSAGE,"Configuring color depth: $(LVGL_COLOR_DEPTH)")
	@sed -i "s|^#define LV_COLOR_DEPTH.*|#define LV_COLOR_DEPTH $(LVGL_COLOR_DEPTH)|" $(@D)/lv_conf.h
endef

define CONFIGURE_DISPLAY_BACKEND
	@$(call MESSAGE,"Configuring $(LVGL_DISPLAY_BACKEND) backend")
	@if [[ $(LVGL_DISPLAY_BACKEND) == "wayland" ]]; then \
		sed -i 's|^#define LV_USE_WAYLAND.*|#define LV_USE_WAYLAND          1|' $(@D)/lv_conf.h; \
	 fi
	@if [[ $(LVGL_DISPLAY_BACKEND) == "fbdev" ]]; then \
		sed -i 's|^#define LV_USE_LINUX_FBDEV.*|#define LV_USE_LINUX_FBDEV      1|' $(@D)/lv_conf.h; \
	 fi
	@if [[ $(LVGL_DISPLAY_BACKEND) == "DRM" ]]; then \
		sed -i 's|^#define LV_USE_LINUX_DRM.*|#define LV_USE_LINUX_DRM        1|' $(@D)/lv_conf.h; \
	 fi
endef

define ENABLE_LV_CONF
	@$(call MESSAGE,"Configuring lv_conf.h")
	@cp -f $(@D)/lv_conf_template.h $(@D)/lv_conf.h
        @sed -i 's|^#if .*Set this to "1" to enable content.*|#if 1 /* Set this to "1" to enable content */|' $(@D)/lv_conf.h
endef

define CONFIGURE_BUILD_DEMOS
	@if grep -q "^BR2_LVGL_BUILD_DEMOS=y" ${BR2_CONFIG}; then \
		$(call MESSAGE,"Configuring build demos (on)"); \
		sed -i "s|^#define LV_BUILD_DEMOS.*|#define LV_BUILD_DEMOS 1|" $(@D)/lv_conf.h; \
		if grep -q "^BR2_LVGL_WIDGETS_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build widgets demo"); \
			sed -i "s|.*#define LV_USE_DEMO_WIDGETS.*|    #define LV_USE_DEMO_WIDGETS 1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_KEYBOARD_ENCODER_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build keyboard and encoder demo"); \
			sed -i "s|.*#define LV_USE_DEMO_KEYPAD_AND_ENCODER.*|    #define LV_USE_DEMO_KEYPAD_AND_ENCODER 1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_BENCHMARK_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build benchmark demo"); \
			sed -i "s|.*#define LV_USE_DEMO_BENCHMARK.*|    #define LV_USE_DEMO_BENCHMARK 1|" $(@D)/lv_conf.h; \
			if grep -q "^BR2_LVGL_BENCHMARk_ALIGNED_FONTS=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring benchmark aligned fonts"); \
				sed -i "s|.*#define LV_DEMO_BENCHMARK_ALIGNED_FONTS.*|        #define LV_DEMO_BENCHMARK_ALIGNED_FONTS 1|" $(@D)/lv_conf.h; \
			fi \
		fi; \
		if grep -q "^BR2_LVGL_RENDER_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build render demo"); \
			sed -i "s|.*#define LV_USE_DEMO_RENDER.*|    #define LV_USE_DEMO_RENDER 1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_STRESS_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build stress demo"); \
			sed -i "s|.*#define LV_USE_DEMO_STRESS.*|    #define LV_USE_DEMO_STRESS 1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_MUSIC_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build music demo"); \
			sed -i "s|.*#define LV_USE_DEMO_MUSIC.*|    #define LV_USE_DEMO_MUSIC 1|" $(@D)/lv_conf.h; \
			sed -i "s|.*#define LV_FONT_MONTSERRAT_22.*|#define LV_FONT_MONTSERRAT_22 1|" $(@D)/lv_conf.h; \
			sed -i "s|.*#define LV_FONT_MONTSERRAT_32.*|#define LV_FONT_MONTSERRAT_32 1|" $(@D)/lv_conf.h; \
			if grep -q "^BR2_LVGL_MUSIC_SQUARE=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring music square"); \
				sed -i "s|.*#define LV_DEMO_MUSIC_SQUARE.*|        #define LV_DEMO_MUSIC_SQUARE    1|" $(@D)/lv_conf.h; \
			fi; \
			if grep -q "^BR2_LVGL_MUSIC_LANDSCAPE=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring music landscape"); \
				sed -i "s|.*#define LV_DEMO_MUSIC_LANDSCAPE.*|        #define LV_DEMO_MUSIC_LANDSCAPE 1|" $(@D)/lv_conf.h; \
			fi; \
			if grep -q "^BR2_LVGL_MUSIC_ROUND=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring music round"); \
				sed -i "s|.*#define LV_DEMO_MUSIC_ROUND.*|        #define LV_DEMO_MUSIC_ROUND     1|" $(@D)/lv_conf.h; \
			fi; \
			if grep -q "^BR2_LVGL_MUSIC_LARGE=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring music large"); \
				sed -i "s|.*#define LV_DEMO_MUSIC_LARGE.*|        #define LV_DEMO_MUSIC_LARGE     1|" $(@D)/lv_conf.h; \
			fi; \
			if grep -q "^BR2_LVGL_MUSIC_AUTO_PLAY=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring music auto play"); \
				sed -i "s|.*#define LV_DEMO_MUSIC_AUTO_PLAY.*|        #define LV_DEMO_MUSIC_AUTO_PLAY 1|" $(@D)/lv_conf.h; \
			fi \
		fi; \
		if grep -q "^BR2_LVGL_VECTOR_GRAPHIC_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build vector graphic demo"); \
			sed -i "s|.*#define LV_USE_DEMO_VECTOR_GRAPHIC.*|    #define LV_USE_DEMO_VECTOR_GRAPHIC  1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_FLEX_LAYOUT_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build flex layout demo"); \
			sed -i "s|.*#define LV_USE_DEMO_FLEX_LAYOUT.*|    #define LV_USE_DEMO_FLEX_LAYOUT     1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_MULTILANG_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build multilang demo"); \
			sed -i "s|.*#define LV_USE_DEMO_MULTILANG.*|    #define LV_USE_DEMO_MULTILANG       1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_TRANSFORM_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build transform demo"); \
			sed -i "s|.*#define LV_USE_DEMO_TRANSFORM.*|    #define LV_USE_DEMO_TRANSFORM       1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_SCROLL_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build scroll demo"); \
			sed -i "s|.*#define LV_USE_DEMO_SCROLL.*|   #define LV_USE_DEMO_SCROLL          1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_EBIKE_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build ebike demo"); \
			sed -i "s|.*#define LV_USE_DEMO_EBIKE.*|    #define LV_USE_DEMO_EBIKE           1|" $(@D)/lv_conf.h; \
			if grep -q "^BR2_LVGL_EBIKE_PORTRAIT=y" ${BR2_CONFIG}; then \
				$(call MESSAGE,"Configuring ebike portrait"); \
				sed -i "s|.*#define LV_DEMO_EBIKE_PORTRAIT.*|        #define LV_DEMO_EBIKE_PORTRAIT  1|" $(@D)/lv_conf.h; \
			fi \
		fi; \
		if grep -q "^BR2_LVGL_HI_RES_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build hi-res demo"); \
			sed -i "s|.*#define LV_USE_DEMO_HIGH_RES.*|    #define LV_USE_DEMO_HIGH_RES        1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_SMARTWATCH_DEMO=y" ${BR2_CONFIG}; then \
			$(call MESSAGE,"Configuring build smartwatch demo"); \
			sed -i "s|.*#define LV_USE_DEMO_SMARTWATCH.*|    #define LV_USE_DEMO_SMARTWATCH      1|" $(@D)/lv_conf.h; \
		fi \
	 else \
		$(call MESSAGE,"Configuring build demos (off)"); \
		sed -i "s|^#define LV_BUILD_DEMOS.*|#define LV_BUILD_DEMOS 0|" $(@D)/lv_conf.h; \
	 fi
endef

define CONFIGURE_WAYLAND_OPTION
	@if grep -q "^BR2_LVGL_WAYLAND_BUILD_OPTIONS=y" ${BR2_CONFIG}; then \
		$(call MESSAGE,"Configuring wayland option"); \
		if grep -q "^BR2_LVGL_WAYLAND_WINDOW_DECORATION=y" ${BR2_CONFIG}; then \
			sed -i "s|.*#define LV_WAYLAND_WINDOW_DECORATIONS.*|    #define LV_WAYLAND_WINDOW_DECORATIONS   1|" $(@D)/lv_conf.h; \
		fi; \
		if grep -q "^BR2_LVGL_WAYLAND_WL_SHELL=y" ${BR2_CONFIG}; then \
			sed -i "s|.*#define LV_WAYLAND_WL_SHELL.*|    #define LV_WAYLAND_WL_SHELL             1|" $(@D)/lv_conf.h; \
		fi; \
	fi
endef

define CONFIGURE_MULTI_TOUCH_GESTURE
	@if grep -q "^BR2_LVGL_MULTI_TOUCH_GESTURE_RECOGNITION=y" ${BR2_CONFIG}; then \
		$(call MESSAGE,"Configuring multi-touch gesture recognition"); \
		sed -i "s|.*#define LV_USE_GESTURE_RECOGNITION.*|#define LV_USE_GESTURE_RECOGNITION 1|" $(@D)/lv_conf.h; \
		sed -i "s|.*#define LV_USE_FLOAT.*|#define LV_USE_FLOAT            1|" $(@D)/lv_conf.h; \
	fi 
endef

define CONFIGURE_LOG_MODULE
	@if grep -q "^BR2_LVGL_LOG_MODULE=y" ${BR2_CONFIG}; then \
		$(call MESSAGE,"Configuring log module (enable) "); \
		sed -i "s|.*#define LV_USE_LOG.*|#define LV_USE_LOG 1|" $(@D)/lv_conf.h; \
	fi
endef

define CONFIGURE_STDLIB_IMPLEMENTATION
	@$(call MESSAGE,"Configuring stdlib implementation"); \
	sed -i "s|.*#define LV_USE_STDLIB_MALLOC.*|#define LV_USE_STDLIB_MALLOC    LV_STDLIB_CLIB|" $(@D)/lv_conf.h; \
	sed -i "s|.*#define LV_USE_STDLIB_STRING.*|#define LV_USE_STDLIB_STRING    LV_STDLIB_CLIB|" $(@D)/lv_conf.h; \
	sed -i "s|.*#define LV_USE_STDLIB_SPRINTF.*|#define LV_USE_STDLIB_SPRINTF   LV_STDLIB_CLIB|" $(@D)/lv_conf.h
endef

define CONFIGURE_EVDEV_INPUT_DEVICE
	@$(call MESSAGE,"Configuring evdev input device"); \
	if grep -q -E "^BR2_LVGL_FBDEV_BACKEND=y|^BR2_LVGL_DRM_BACKEND=y" ${BR2_CONFIG}; then \
		sed -i "s|.*#define LV_USE_EVDEV.*|#define LV_USE_EVDEV    1|" $(@D)/lv_conf.h; \
	fi
endef

define GENERATE_LV_CONF_FILE
	$(ENABLE_LV_CONF)
	$(CONFIGURE_COLOR_DEPTH)
	$(CONFIGURE_STDLIB_IMPLEMENTATION)
	$(CONFIGURE_LOG_MODULE)
	$(CONFIGURE_DISPLAY_BACKEND)
	$(CONFIGURE_EVDEV_INPUT_DEVICE)
	$(CONFIGURE_MULTI_TOUCH_GESTURE)
	$(CONFIGURE_WAYLAND_OPTION)
	$(CONFIGURE_BUILD_DEMOS)
endef
LVGL_PRE_CONFIGURE_HOOKS += GENERATE_LV_CONF_FILE

LVGL_CONF_OPTS = -DLV_CONF_INCLUDE_SIMPLE=$(@D)
LVGL_CONF_OPTS += -DCONFIG_LV_USE_PRIVATE_API=ON

define REMOVE_TARGET_HEADER_FILES
	rm -Rf $(TARGET_DIR)/usr/include/lvgl
	rm -Rf $(TARGET_DIR)/usr/share/pkgconfig
endef
LVGL_POST_INSTALL_TARGET_HOOKS += REMOVE_TARGET_HEADER_FILES

$(eval $(cmake-package))
