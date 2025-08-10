# Cross-Compilation SDK & Docker Images

This SDK and its corresponding Docker images provide a modern Clang/LLVM-based toolchain and prebuilt sysroots for targeting:

- **Linux x86_64 (glibc)**
- **Linux aarch64 (glibc)**
- **Windows x86_64 (MinGW-w64)**
- **Windows aarch64 (MinGW-w64)**

---

## Components and Licensing

This SDK is composed entirely of free and open-source software built from publicly available sources. Redistribution is permitted under the terms of the respective licenses.

### 1. Debian GNU/Linux Packages
- **Source:** [Debian Project](https://www.debian.org/) (`deb.debian.org`)
- **License:** Various free/open-source licenses (GPL, LGPL, MIT, BSD, ISC, public domain).
- **Notes:** Debian's [Social Contract](https://www.debian.org/social_contract) guarantees that all main repository packages are free to distribute.

### 2. MinGW-w64 Toolchain (Windows Target Support)
- **Source:** [MinGW-w64 Project](http://mingw-w64.org/) (via Debian packages)
- **License:** GNU GPL v3 (build system), GNU LGPL v3+ (runtime libraries), permissive licenses for headers.
- **Notes:** Redistribution permitted under the terms of the respective licenses.

### 3. LLVM, Clang, LLD, and Related Tools
- **Source:** [LLVM Project](https://llvm.org/) (via [apt.llvm.org](https://apt.llvm.org/))
- **License:** Apache License v2.0 with LLVM Exceptions ([license text](https://llvm.org/docs/DeveloperPolicy.html#new-code-license)).
- **Notes:** Redistribution is permitted provided license and copyright
  notices are retained.

---

## Disclaimer

This SDK and Docker images are provided “as-is” without warranty of any kind.  
You are responsible for compliance with the licenses of included components and for ensuring that any additional software you add complies with its own licensing terms.
