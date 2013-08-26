# C is variable for command. If you want to move files instead of symlinks use
#C=cp
C=ln -s
DESTDIR=~

.PHONY: X all gtk help ncmpcpp tmux zsh

help:
	@echo "Use \`make <target>\` where <target> is one of"
	@echo " all     Installs all described below"
	@echo " X       Installs .Xdefaults and .xinitrc"
	@echo " gtk     Installs .gtkrc"
	@echo " ncmpcpp Installs .ncmpcpp"
	@echo " tmux    Installs .tmuxrc"
	@echo " zsh     Installs .zshrc and dependencies"

all: X gtk ncmpcpp tmux zsh

X:
	$(C) $(CURDIR)/Xdefaults $(DESTDIR)/.Xdefaults
	$(C) $(CURDIR)/xinitrc $(DESTDIR)/.xinitrc

gtk:
	$(C) $(CURDIR)/gtkrc-2.0 $(DESTDIR)/.gtkrc-2.0

ncmpcpp:
	$(C) $(CURDIR)/ncmpcpp $(DESTDIR)/.ncmpcpp

tmux:
	$(C) $(CURDIR)/tmux.conf $(DESTDIR)/.tmux.conf

zsh:
	$(C) $(CURDIR)/zsh_aliases $(DESTDIR)/.zsh_aliases
	$(C) $(CURDIR)/zsh_functions $(DESTDIR)/.zsh_functions
	$(C) $(CURDIR)/zshrc $(DESTDIR)/.zshrc


