# fish shell completions for gcloud CLI

The CLI for Google Cloud Platform, **gcloud**, ships with terminal completions for bash and zsh, but not for fish. This script adds those completions to the fish shell.

It is a direct copy of the functionalty in the bash and zsh completions scripts (included in the reference folder for, well, reference). Note that it's not insanely performant since it launches a Python interpreter for each completion (a trait it shares with Google's original scripts), but unless you have blazing fingers of fury and/or a very slow computer, that shouldn't be noticeable in regular use.

To install, copy the script into `~/.config/fish/conf.d/` and restart your fish shell (`exec fish` will do it if you don't want to close your terminal).

Or you can simply use the one-line command below (it will create that fish config directory if it doesn't already exist):

```
curl -sL https://raw.githubusercontent.com/robfahey/gcloud-fish-completions/main/gcloud-completions.fish | (mkdir -p ~/.config/fish/conf.d && cat > ~/.config/fish/conf.d/gcloud-completions.fish)
```