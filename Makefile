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
	@echo " ncmpc++ Installs .ncmpcpp"
	@echo " tmux    Installs .tmuxrc"
	@echo " zsh     Installs .zshrc and dependencies"
	@echo ""
	@echo "Each option also have backup-<target> version to backup your existing files"

backup-all: backup-X backup-gtk backup-ncmpc++ backup-tmux backup-zsh

all: X gtk ncmpc++ tmux zsh

backup-X: Xdefaults xinitrc
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f).bak;)

X: Xdefaults xinitrc
	$(foreach f, $?, $(C) $(CURDIR)/$(f) $(DESTDIR)/.$(f);)

backup-gtk: gtkrc-2.0
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f).bak;)

gtk: gtkrc-2.0
	$(foreach f, $?, $(C) $(CURDIR)/$(f) $(DESTDIR)/.$(f);)

backup-ncmpc++: ncmpcpp
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f)/config.bak;)

ncmpc++: ncmpcpp
	$(foreach f, $?, $(C) $(CURDIR)/$(f) $(DESTDIR)/.$(f)/config;)

backup-tmux: tmux.conf
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f).bak;)

tmux: tmux.conf
	$(foreach f, $?, $(C) $(CURDIR)/$(f) $(DESTDIR)/.$(f);)

backup-zsh: zsh_aliases zsh_functions zshrc
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f).bak;)

zsh: zsh_aliases zsh_functions zshrc
	$(foreach f, $?, $(C) $(CURDIR)/$(f) $(DESTDIR)/.$(f);)

