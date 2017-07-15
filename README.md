# knSlate
A simple, flat theme for the  Linux GRUB loader

---

### Installation (Lazy)

  1. Download ZIP, unzip.
  2. Open terminal, navigate into the unzipped folder **`cd /path/to/folder`**
  3. Run the install script **`sudo ./install.sh`** with superuser permissions
  4. Follow instructions
  5. Reboot
  
---
  
### Installation (Manual)

  1. Download ZIP, unzip.
  2. Open terminal.
  3. Copy the theme folder **`sudo cp ~/path/to/theme/knSlate/ /boot/grub/themes/ -r`**
  4. Change theme in configuration file **`sudo gedit /etc/default/grub`** to knSlate
  5. Build new GRUB configuration file **`sudo grub-mkconfig -o /boot/grub/grub.cfg`**
  6. Reboot
