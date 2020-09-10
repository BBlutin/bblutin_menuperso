# [BETA] bblutin_menuperso
 > [EN] A personnal menu for ESX build in [NativeUI](https://github.com/FrazzIe/NativeUILua) and including [DPEmotes](https://github.com/andristum/dpemotes)

 > [FR] Un menu personnel pour ESX fait en [NativeUI](https://github.com/FrazzIe/NativeUILua) et incluant [DPEmotes](https://github.com/andristum/dpemotes)

[![TITRE](https://i.imgur.com/kosIXHU.png)]()

### [EN]
```
This script is still in BETA. A lot of improvement will be done on the animation and admin part in the future. 
If you have suggestions or want to collaborate, feel free to contact me ;)
```

### [FR]
```
Ce script est en BETA. Une grande quantité d'améliorations vont être apportées au niveau des animations et de la partie admin. 
Si vous avez des suggestions ou voulez collaborer avec moi, n'hésitez pas à me contacter ;)
```

---
## ⚡ Installation 

How to get started with the script

### Download

- You can clone this repo to your local machine using :
```
cd resources 
git clone https://github.com/BBlutin/bblutin_menuperso.git
```

- Or you can download it manually :

  - Download https://github.com/BBlutin/bblutin_menuperso/archive/master.zip
  - Put it in the [esx] directory
  
### Import SQL & Start

- Import `keybinds.sql` in your database
- Add this to your `server.cfg`:
```
ensure bblutin_menuperso
```

---

## 📺 Preview

[![Aperçu](https://i.imgur.com/SghrOL4.png)](https://streamable.com/guk2hz)

---

## 📋 Structure

### 📂 bblutin_menuperso

- **📂 client**

  - 📄 main.lua
  - 📄 animlist.lua
  - 📄 emote.lua
  - 📄 syncing.lua

- **📂 server**

  - 📄 main.lua
  - 📄 server.lua

- **📂 dependencies**

    - All the NativeUI stuff

- **📂 html**

    - Files to create the Cinematic overlay

- **📂 locales**

    - 📄 fr.lua

- **📂 stream**

    - Custom Anims

- 📄 __resource.lua

- 📄 config.lua

- 📄 keybinds.sql

---
## 💜 Special thanks

A big thanks to [Dullpear](https://github.com/andristum) for his great emote script and to [FrazzIe](https://github.com/FrazzIe) for the NativeUI

---

## 🔰 License

Copyright (C) 2020 BBlutin

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.