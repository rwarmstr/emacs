## Emacs Configuration Files

These Emacs configuration files set up a C/C++, Python, and Vivado build
environment suitable for users of Xilinx FPGAs.

### Installation

1. Remove or rename the existing .emacs file in your home directory and the
   .emacs.d/ directory, if they exist.

2. Clone this repository into your home directory

```
cd
git clone https://github.com/rwarmstr/emacs.git .emacs.d
```

3. Launch emacs and install the Irony server for autocomplete. Note that this
   assumes you already have the prerequisite clang environment installed.

`M-x irony-install-server`

