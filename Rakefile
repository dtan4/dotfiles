LINUX_ONLY = %w(.conkyrc .Xresources)
MAC_ONLY = %w(.tmux-Darwin.conf)

ANYENV_DIR = File.join(ENV["HOME"], ".anyenv")

ANYENV_PLUGINS = {
  "anyenv-update" => "znz/anyenv-update"
}

RBENV_PLUGINS = {
  "gem-src" => "amatsuda/gem-src",
  "rbenv-default-gems" => "sstephenson/rbenv-default-gems",
  "rbenv-gem-rehash" => "sstephenson/rbenv-gem-rehash",
}

task default: "update"

desc "Clean up .vim/bundle"
task :clean => [
  "clean:symlink",
  "clean:vim_plugin"
] do
end

desc "Install dotfiles"
task :install => [
  "submodule:init",
  "install:anyenv",
  "install:homebrew",
  "install:envchain",
  "symlink"
] do
end

desc "Create symlinks"
task :symlink do
  symlink_ignore = open(File.join(Dir.pwd, ".symlinkignore")).read.split("\n")

  Dir.glob("*", File::FNM_DOTMATCH) do |file|
    next if %w(. ..).include?(file)
    next if symlink_ignore.include?(file)
    next if darwin? && MAC_ONLY.include?(file)
    next if linux? && LINUX_ONLY.include?(file)

    source = File.join(Dir.pwd, file)
    target = File.join(ENV["HOME"], file)

    File.delete(target) if Dir.exist?(source) && File.exist?(target)

    ln_sf(source, target)
  end
end

desc "Update dotfiles"
task :update => [
  "submodule:update",
  "install:anyenv_plugins",
  "install:rbenv_plugins",
  "symlink"
] do
end

namespace :clean do
  desc "Clean up symlinks"
  task :symlink do
    Dir.glob("*", File::FNM_DOTMATCH) do |file|
      next if %w(. ..).include?(file)
      target = File.join(ENV["HOME"], file)
      rm_r(target) if File.exists?(target) || Dir.exists?(target)
    end
  end

  desc "Clean up vim plugins"
  task :vim_plugin do
    Dir.glob(".vim/bundle/*") do |dir|
      rm_r dir unless /neobundle\.vim\z/ =~ dir
    end
  end
end

namespace :homebrew do
  desc "Install Homwbrew"
  task :install do
    if darwin? && !File.exists?("/usr/local/bin/brew")
      sh %(ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")
    end
  end

  desc "Install tools from Brewfile"
  task :bundle do
    brewfile = open(File.join(Dir.pwd, 'brewfiles', 'Brewfile')).read
    brewfile.lines.reject { |line| line.strip.empty? }.each { |line| sh "brew #{line.strip}" }
  end
end

namespace :submodule do
  desc "Install submodules"
  task :init do
    sh %(git submodule update --init)
  end

  desc "Update submodules"
  task :update do
    submodules.each do |submodule|
      Dir.chdir(File.join(Dir.pwd, submodule)) do
        sh %(git pull origin master)
      end
    end
  end
end

namespace :install do
  desc "Install anyenv"
  task :anyenv do
    unless Dir.exists?(ANYENV_DIR)
      clone_from_github("riywo/anyenv", ANYENV_DIR)
      sh %(#{anyenv} init -)
    end

    Rake::Task["install:anyenv_plugins"].invoke

    %w(crenv ndenv plenv rbenv).each do |env|
      Rake::Task["install:#{env}"].invoke
    end
  end

  desc "Install anyenv plugins"
  task :anyenv_plugins do
    ANYENV_PLUGINS.each do |plugin, repository|
      plugin_dir = File.join(ANYENV_DIR, "plugins", plugin)
      next if Dir.exists?(plugin_dir)

      clone_from_github(repository, plugin_dir)
    end
  end

  desc "Install Homebrew"
  task :homebrew => [
    "homebrew:install"
  ] do
  end

  desc "Install crenv"
  task :crenv do
    install_env("crenv")
  end

  desc "Install ndenv"
  task :ndenv do
    install_env("ndenv")
  end

  desc "Install plenv"
  task :plenv do
    install_env("plenv")
  end

  desc "Install rbenv"
  task :rbenv do
    install_env("rbenv")
    Rake::Task["install:rbenv_plugins"].invoke
  end

  desc "Install rbenv plugins"
  task :rbenv_plugins do
    RBENV_PLUGINS.each do |plugin, repository|
      plugin_dir = File.join(ANYENV_DIR, "envs", "rbenv", "plugins", plugin)
      next if Dir.exists?(plugin_dir)

      clone_from_github(repository, plugin_dir)
    end

    source = File.join(Dir.pwd, "default-gems")
    target = File.join(ANYENV_DIR, "envs", "rbenv", "default-gems")

    ln_s(source, target) unless File.exist?(target)
  end

  desc "Install envchain"
  task :envchain do
    if darwin? && !File.exists?("/usr/local/bin/envchain")
      sh %(brew install https://raw.githubusercontent.com/sorah/envchain/master/brew/envchain.rb)
    end
  end

  desc "Install golang toolchain"
  task "gotools" do
    %w(
      github.com/nsf/gocode
      github.com/rogpeppe/godef
      golang.org/x/tools/cmd/godoc
    ).each do |tool|
      sh %(go get #{tool})
    end
  end
end

private

def anyenv
  File.join(ANYENV_DIR, "bin", "anyenv")
end

def clone_from_github(repository, target_dir)
  sh %(git clone --recursive https://github.com/#{repository}.git #{target_dir})
end

def darwin?
  uname == "Darwin"
end

def env_installed?(env)
  `#{anyenv} envs`.split("\n").include?(env)
end

def install_env(env)
  sh %(#{anyenv} install #{env}) unless env_installed?(env)
end

def linux?
  uname == "Linux"
end

def uname
  `uname`.strip
end


#
# $ git submodule
#  f75ba16d5f8276b6f8d08b73f0e2e35a40719251 .tmux/plugins/tpm (v1.2.2-85-gf75ba16)
#  e7c1e4122b1d1ec1841256abeb7999758aaa9fca .vim/bundle/neobundle.vim (ver.3.2-30-ge7c1e41)
#                                           ^^^^^^^^^^^^^^^^^^^^^^^^^
#
def submodules
  `git submodule`.lines.map { |line| line.split(" ")[1] }
end
