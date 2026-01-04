# PEDSCII

Commodore 64 editor based on the Power C editor, with these changes:

* Using the standard PETSCII character set (from ASCII)
* No color changes
* You can switch between the shifted and unshifted charecter set.
* Build configuration (see features.inc)
* Loads and runs as standard program
* Removed unnecessary functionality (printing, saving and restoring zero page) to make this program smaller
* Ability to edit files up to ___ KB, by using the RAM under IO and kernal.
* Shortcuts more like Windows standard. Unfortunately, <CTRL>+<C> is not possible for copy because that is the same as the <RUN STOP> key used for command mode and for select mode with <SHIFT>.
* No more self-modifying code.
* Command mode now returns to edit mode after (attempting) command execution.

# Build tools

* PMP
* ca65
* ld65
* x64sc
