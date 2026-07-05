# Мод для установки доброй колоды в DOTA2

# Слушаем балдеем

[![YANDEXMUSIC](https://img.shields.io/badge/YANDEXMUSIC-yellow?style=for-the-badge)](https://music.yandex.ru/artist/23645333)
[![TELEGRAM](https://img.shields.io/badge/VKMUSIC-darkblue?logo=VK&style=for-the-badge)](https://vk.com/artist/5410374050909052816)
[![TELEGRAM](https://img.shields.io/badge/TELEGRAM-blue?logo=telegram&style=for-the-badge)](https://t.me/meowthpxnk)

## Как установить мод через Installer.bat

1. Скачайте последний релиз распакуйте файлы в любую папку.
2. Запустить Installer.bat[^2]
   Ниже расписано что делает батник[^3], если ссытесь закиньте содержимое батника в нейронку и прогоните, так же для боящихся скину гайд ручной установки.
3. Выбрать патч
   sovanaskakalke - все меняется на сову, так же как на видосе в тиктоке
   dobraya_coloda - колода из 11 самых добрых карт + кастом предсказания
4. Зайти в доту получить добрые предсказания!

## Ручная установка мода

1.  Скачайте последний релиз распакуйте файлы в любую папку.[^1]
2.  Файлы из папки patches киньте в папку game
3.  Измените файл game/dota/gameinfo_branchspecific.gi

    dobraya_coloda - колода из 11 самых добрых карт + кастом предсказания

    ```
    SearchPaths
    {
        Game_Language    dota_*LANGUAGE*
        Game_LowViolence  dota_lv
        Game      dobraya_coloda
        Game      dota
        Game      core
        Mod      dobraya_coloda
        Mod      dota
        Write      dota
        AddonRoot_Language  dota_*LANGUAGE*_addons
        AddonRoot    dota_addons
        PublicContent    dota_core
        PublicContent    core
    }
    ```

    sovanaskakalke - все меняется на сову, так же как на видосе в тиктоке

    ```
    {
        Game*Language dota*_LANGUAGE_
        Game*LowViolence dota_lv
        Game sovanaskakalke
        Game dota
        Game core
        Mod sovanaskakalke
        Mod dota
        Write dota
        AddonRoot_Language dota*_LANGUAGE_\_addons
        AddonRoot dota_addons
        PublicContent dota_core
        PublicContent core
    }

    ```

    Пример файла до

    ```

    "GameInfo"
    {
    //
    // Branch-varying info, such as the game/title and app IDs, is in gameinfo_branchspecific.gi.
    // gameinfo.gi is the non-branch-varying content and can be integrated between branches.
    //

        game 		"Dota 2"
        title 		"Dota 2"

        FileSystem
        {
        	SteamAppId				570
        	BreakpadAppId			373300	// Report crashes under beta DLC, not the S1 game.  Delete this when all clients are switched to S2
        	BreakpadAppId_Tools		375360  // Use a separate bucket of buckets for "-tools" crashes so that they don't get drowned out by game crashes. Falls back to  BreakpadAppId/SteamAppId if missing
        }

    }

    ```

    Пример файла после:

    ```

    "GameInfo"
    {
    //
    // Branch-varying info, such as the game/title and app IDs, is in gameinfo_branchspecific.gi.
    // gameinfo.gi is the non-branch-varying content and can be integrated between branches.
    //

        game 		"Dota 2"
        title 		"Dota 2"

        FileSystem
        {
        	SteamAppId				570
        	BreakpadAppId			373300	// Report crashes under beta DLC, not the S1 game.  Delete this when all clients are switched to S2
        	BreakpadAppId_Tools		375360  // Use a separate bucket of buckets for "-tools" crashes so that they don't get drowned out by game crashes. Falls back to  BreakpadAppId/SteamAppId if missing
        	SearchPaths
        		{
          			Game_Language    dota_*LANGUAGE*
          			Game_LowViolence  dota_lv
          			Game      dobraya_coloda
          			Game      dota
          			Game      core
          			Mod      dobraya_coloda
          			Mod      dota
          			Write      dota
          			AddonRoot_Language  dota_*LANGUAGE*_addons
          			AddonRoot    dota_addons
          			PublicContent    dota_core
          			PublicContent    core
        		}
        		"UserSettingsPathID"  "USRLOCAL"
        		"LegacyUserSettingsPathID"  "MOD"
        		AddonsChangeDefaultWritePath 0
        }

    }

    ```

    ```

    ```

## Сноски

[^1]: Как открыть файлы доты? Пкм по доте в steam -> Управление -> Посмотреть локальные файлы

[^2]: Если патч после апдейта слетел то еще раз запустите Installer.bat

[^3]: Installer.bat меняет файл доты gameinfo_branchspecific.gi, закидывает мод в папки рядом с дотой, делает посути тоже самое что и в ручной установке
