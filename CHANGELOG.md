## 1.0.3

* Added support for a custom API URL, receive timeout, and cache backend. ([#4](https://github.com/ThisIsMonta/iconify_design_flutter/pull/4))
* Fixed an async cache lookup that could store an SVG under the wrong key when an `IconifyIcon` changed during loading.

## 1.0.2
* Fixed icon rendering when `color` is set to `null`; it now falls back to black. ([#1](https://github.com/ThisIsMonta/iconify_design_flutter/issues/1))
* Added support for custom loading placeholders with `placeholder` and custom error widgets with `errorWidget`, requested by [@Matej-Hlatky](https://github.com/Matej-Hlatky). ([#2](https://github.com/ThisIsMonta/iconify_design_flutter/issues/2))
* Improved the example app and widget tests.

## 1.0.1
* Caching support.
* Documentation added.

## 1.0.0
* Initial release.
