[app]

# (str) Title of your application
title = CBSE Study Assistant

# (str) Package name
package.name = studyassistant

# (str) Package domain (needs at least 2 dots)
package.domain = com.cbse

# (str) Source code directory
source.dir = .

# (list) Source files to include (extensions)
source.include_exts = py,png,jpg,kv,atlas,ttf,csv,json

# (list) Source files to exclude from the source.dir
source.exclude_exts = spec

# (list) List of inclusions using glob patterns
source.include_patterns = cbse_chapters.csv

# (str) Application versioning
version = 1.0.0

# (str) Application versioning (int)
# version.code = 1

# (str) Requirements (comma separated)
requirements = python3,kivy==2.3.1,kivymd==1.2.0,pillow,pygments

# (str) Orientation (one of portrait, landscape, sensor)
orientation = portrait

# (bool) Indicate if the application should be fullscreen
fullscreen = 0

# (list) Application permissions
android.permissions =

# (int) Android API level to use
android.api = 34

# (int) Minimum API level
android.minapi = 26

# (int) Android SDK version to use
android.sdk = 34

# (str) Android NDK version to use
android.ndk = 25c

# (bool) Use AndroidX library
android.use_androidx = True

# (str) Path to Android app icon in PNG format (optional)
# icon.filename = %(source.dir)s/icon.png

# (str) Path to Android presplash image in PNG format (optional)
# presplash.filename = %(source.dir)s/splash.png

# (str) Android logcat filter expression
# logcat_filter = *:S python:D

# (str) Android additional library dependencies
# android.gradle_dependencies = []

# (str) Android additional library dependencies
# android.gradle_dependencies = []

# (str) Python for Android branch to use
# p4a.branch = develop

# (str) Python for Android git clone URL
# p4a.url = https://github.com/kivy/python-for-android.git

# (str) Local recipes directory
# p4a.local_recipes =

# (str) The Android arch to build for (armeabi-v7a, arm64-v8a, x86, x86_64)
android.archs = arm64-v8a

# (str) After Buildozer builds the APK, sign it with this key alias
# android.keystore_alias =

# (str) Path to the keystore
# android.keystore =

# (str) Password for the keystore
# android.keystore_password =

# (bool) Strip the APK to reduce its size
android.strip = True

# (str) Path to a custom build profile
# build_profile =

# Private section for development
[buildozer]

# (int) Log level (0 = error only, 1 = info, 2 = debug)
log_level = 2

# (str) Path to the build directory
build_dir = ./.buildozer

# (str) Path to the bin directory (generated APKs)
bin_dir = ./bin
