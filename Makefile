# C is variable for command. If you want to move files instead of symlinks use
#C=cp
C=ln -sfn
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

backup-X: Xdefaults xinitrc xprofile
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f).bak;)

X: Xdefaults xinitrc xprofile
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

backup-zsh: zsh_aliases zsh_functions zshrc .zsh
	$(foreach f, $?, mv $(DESTDIR)/.$(f) $(DESTDIR)/.$(f).bak;)

zsh: zsh_aliases zsh_functions zshrc
	wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/terraform/_terraform -O zsh/completion/_terraform
	wget https://raw.githubusercontent.com/hanjunlee/terragrunt-oh-my-zsh-plugin/master/_terragrunt -O zsh/completion/_terragrunt
	test -d zsh/zsh-autosuggestions || git clone --branch v0.6.4 https://github.com/zsh-users/zsh-autosuggestions zsh/zsh-autosuggestions
	$(C) $(CURDIR)/zsh $(DESTDIR)/.zsh
	$(foreach f, $?, $(C) $(CURDIR)/$(f) $(DESTDIR)/.$(f);)
