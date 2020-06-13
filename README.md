<img src="https://raw.githubusercontent.com/CosasDePuma/CV/master/.github/readme/logo.png" align="right" width="150">

# Currículum Vítae
[![LinkedIn](https://img.shields.io/badge/kikefontan-blue.svg?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/kikefontan)
[![Download (ES)](https://img.shields.io/badge/download-espa%C3%B1ol-green.svg?style=for-the-badge)](https://github.com/CosasDePuma/CV/releases/download/espa%C3%B1ol/curriculum.pdf)

Here's my resume, my CV, my X. It is completely made using Latex and Vim, because as a programmer I refused to use conventional and simple text editors. All my accomplishments are listed very briefly (or at least I tried to) in the pages that make it up.

Also, something totally incredible and absolutely useless in the eyes of many recruiters is that...

    IT'S NOT ONLY A PDF, IT'S ALSO A BOOTLOADER


### 💭 How it is possible?
---
Very simply.

Having programmed a `bootloader`, just copy the binary file after the PDF header. This way, PDF readers will be able to handle the file in the usual way, **but so will computers and emulators!**

### 🏃 How can I run it?
---
You can boot a USB using tools like `dd`, [`Win32 Disk Imager`](https://sourceforge.net/projects/win32diskimager/) or any [other standard flashing method](https://wiki.archlinux.org/index.php/USB_flash_installation_medium_(Espa%C3%B1ol)). Personally I haven't tried any, so if any error appears don't hesitate to [report it](https://github.com/CosasDePuma/CV/issues) to me.

In my personal case I use 'qemu'. If you have it installed on your system, you only need to run the following command to check how cool the secret functionality is:

```sh
# Option 1
qemu-system-i386 curriculum.pdf
# Option 2
qemu-system-x86_64 curriculum.pdf

# How to fix warning logs
qemu-system-i386 -driver format=raw,file=curriculum.pdf
```

### 💾 Demostration
---
![Demo](https://raw.githubusercontent.com/CosasDePuma/CV/master/.github/readme/demo.gif)