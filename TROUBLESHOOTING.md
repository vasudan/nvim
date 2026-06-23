
# Nvim not loading environment variables or full PATH

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

