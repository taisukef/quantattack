# QuantAttack

## lua version

### how to build

1. Install Python (3 version 3.4 or later)
2. Download and unpack [picotool-master.zip](https://github.com/dansanderson/picotool/archive/master.zip), or use Git to clone [picotool](https://github.com/dansanderson/picotool)
3. ```pip install .``` on the picotool path
4. Install lua, luarocks
```
# for Mac
brew install lua luarocks
 luarocks
```
6. Install busted (for Mac)
```
luarocks install busted
luarocks install LuaCov
luarocks install lua-compat
```
7. ```rake build:debug```
8. run

### how to build web app → NG

```
sh export_and_patch_cartridge_release.sh
```

### how to run → NG

```
PICO-8.app/Contents/MacOS/pico8 quantattack/v0.7.5_release/quantattack_vs_human.p8
```

### test

```rake test``` → NG

## js ver (under construction)

### original on web

https://qniapp.github.io/quantattack/

### test

- [pset](https://taisukef.github.io/quantattack/test/pset.html)
- [line](https://taisukef.github.io/quantattack/test/line.html)
- [print](https://taisukef.github.io/quantattack/test/print.html)
- [plasma](https://taisukef.github.io/quantattack/test/plasma.html)
- [title](https://taisukef.github.io/quantattack/test/title.html)

### lua memo

- 配列は1から始まる
- ~= が !=
- flg and 1 or -1 が flg ? 1 : -1
