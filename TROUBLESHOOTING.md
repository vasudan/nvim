# Requirements
- clang
- rustc
- tree-sitter cli


##  Nvim not loading environment variables or full PATH

This is probably because it is not running as an interactive shell, meaning it does not read .bashrc

Either run nvim from a terminal that (so that the terminal has already read .bashrc) or edit .profile to read .bashrc on startup

```bash
# ~/.profile
if [ -f "$HOME/.bashrc" ]; then
. "$HOME/.bashrc"
fi
```

The default .bashrc might have a if-statement that causes it to exit if the shell isn't interactive.
Place the environment variables above this statment 

```bash
export MY_VAR=1
PATH="$HOME/bin:$PATH"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
```

## Treesitter failing to compile on Windows

There needs to be a C compiler installed.
1. Download the [VS Studio build tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
2. Run it and select "Desktop development with c++"
3. Select the default as well as "C++ Clang tools for Windows" and "C++/CLI support"
4. Install it.
5. Rename `C:\Program Files\Neovim\lib\nvim\parsers` to `parsers.old` to avoid parser conflicts
6. Edit system environment variables and create `CC=clang`
7. Open a Developer Powershell window and find the location of the clang binary by running `Get-Command clang`
8. Add the directory it is in to the PATH of the system environment variables
9. Open a new powershell window and start nvim

**Note** If there are a bunch of errors of header files missing when nvim is setting up treesitter then try installing LLVM
  - `winget install LLVM.LLVM`