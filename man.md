# man PEDSCII

## Edit Mode

| Key                 | Command             |
| :-----------------: | :------------------ |
| `F1`                | Page down           |
| `SHIFT`+`F1` (`F2`) | Page up             |
| `F3`                | Search downward     |
| `SHIFT`+`F3` (`F4`) | Search upward       |
| `F5`                | Go to top           |
| `SHIFT`+`F5` (`F6`) | Go to bottom        |
| `F7`                |                     |
| `SHIFT`+`F7` (`F8`) |                     |
| `CLR HOME`          | Go to start of line |
| `SHIFT`+`CLR HOME`  | Go to end of line   |
| `RUN STOP`          | Enter command mode  |
| `SHIFT`+`RUN STOP`  | Enter select mode for Copy/Cut/Delete (again to cancel) |
| `RETURN`            | Split line          |
| `SHIFT`+`RETURN`    | Open a line         |
| `CTRL`+`A`          | Select All          |
| `CTRL`+`C`          | Copy                |
| `CTRL`+`X`          | Cut                 |
| `CTRL`+`V`          | Paste               |

## Command Mode

| Command                          | Description                               |
| :------------------------------- | :---------------------------------------- |
| `DIR`                            | Directory                                 |
| `DISk [STRING]`                  | Disk command                              |
| `GEt <FILE NAME>`                | Load from file                            |
| `PUt <FILE NAME>`                | Save to file                              |
| `GOto BUFFERNAME`                | Change current edit buffer                |
| `List`                           | List buffers currently in use             |
| `CHeck`                          | Check C syntax (`ced.sh` only)            |
| `QUIT`                           | Exit                                      |
| `CLEAR`                          | Clear current buffer                      |
| `CLEAR BUFFERNAME`               | Clear named buffer                        |
| `/searchstring`, `F3`            | Set search string and search down         |
| `/searchstring`, `F4`            | Set search string and search up           |
| `/search/replace`, `F3` or `F4`  | Search and replace one time down/up       |
| `/search/replace/`, `F3` or `F4` | Search and replace all occurences down/up |
| `/search/`, `F3` or `F4`         | Delete next occurence down/up             |
| `/search//`, `F3` or `F4`        | Delete all occurences down/up             |
