# Preforth

A Forth preprocessor written in Forth.

## User manual
### Usage  
```
preforth <input file> <output file>
```
This program parse the input file, searching for some tags. If no tags are found at the beginning of a line, the line is copied on the output file.
List of tags:
* `\ #IN filename` : include non-recursively. Dump the content of `filename` in the output file.
* `\ #IR filename` : include recursively. Process `filename` and put the result in the output file. Similar to #include in C preprocessors.
* `\ #SI` : stop the inclusion. Stop the preprocessing of the file. Useful when used alongside `#IR`.

### Example
Let's imagine we have three files.
file1
```
Some text 1
\ #IN file2
Some text 2
\ #IR file2
Some text 3
```
file2
```
Some text 4
\ #IN file3
Some text 5
\ #SI
Some text 6
```

file3
```
Some text 7
```

If you typed `./preforth file1 file4` the content of file4 would be:
```
Some text 1
Some text 4
\ #IN file3
Some text 5
\ #SI
Some text 6
Some text 2
Some text 4
Some text 7
Some text 5
Some text 3
```
When we included file2 with the tag #IN the tags #IN and #SI inside of file2 were ignored. But when we included it with #IR they were taken into account.

## Utilisation and installation

Preforth is meant to be run with [Gforth](https://gforth.org) or [ASCminiForth](https://github.com/Arkaeriit/ASCminiForth) but it could works with other Forth implementation. A version working with Ciforth can be found in the git branch named `ciforth`.

Here is how you can install it if you want to use Gforth:
```sh
sudo cp preforth.frt /usr/local/bin/
printf '#!/bin/sh\n/usr/bin/env gforth /usr/local/bin/preforth.frt "$@"\n' | sudo tee /usr/local/bin/preforth > /dev/null
sudo chmod +x /usr/local/bin/preforth
```

Here is how you can install it if you want to use ASCminiForth:
```sh
printf '#!/usr/bin/env amforth\n' | sudo tee /usr/local/bin/preforth > /dev/null
cat preforth.frt | sudo tee -a /usr/local/bin/preforth > /dev/null
sudo chmod +x /usr/local/bin/preforth
```

