# Debian
Debian stable slim image with flexible build hooks. The images are publicly available as `hieupth/debian:[tag]`.
Tag|Packages
|-|-|
|none|tini, curl, gnupg, libcap2-bin|
|devel|build-essential, gcc, g++, make, cmake|

There is a non-root user called `nonroot`. If you inherited the image, you can switch user to root to install neccessary packages and then switch back to `debian` user for security purposes.
## License
[GNU AGPL v3.0](LICENSE).<br>
Copyright &copy; 2025 [Hieu Pham](https://github.com/hieupth). All rights reserved.