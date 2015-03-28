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
task :clean do
  Dir.glob(".vim/bundle/*") do |dir|
    rm_r dir unless /neobundle\.vim\z/ =~ dir
  end
end

desc "Install dotfiles"
task :install => [
  "submodule:init",
  "install:anyenv",
  "install:homebrew",
  "symlink"
] do
end

desc "Create symlinks"
task :symlink do
  uname = `uname`.strip
  symlink_ignore = open(File.join(Dir.pwd, ".symlinkignore")).read.split("\n")

  Dir.glob("*", File::FNM_DOTMATCH) do |file|
    next if %w(. ..).include?(file)
    next if symlink_ignore.include?(file)
    next if (uname != "Darwin") && MAC_ONLY.include?(file)
    next if (uname != "Linux") && LINUX_ONLY.include?(file)

    source = File.join(Dir.pwd, file)
    target = File.join(ENV["HOME"], file)

    next if File.exists?(target) || Dir.exists?(target)

    ln_s(source, target)
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

namespace :install do
  desc "Install anyenv"
  task :anyenv do
    unless Dir.exists?(ANYENV_DIR)
      clone_from_github("riywo/anyenv", ANYENV_DIR)
      sh %(#{anyenv} init -)
    end

    Rake::Task["install:anyenv_plugins"].invoke

    %w(rbenv plenv ndenv).each do |env|
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
  task :homebrew do
    exit if File.exists?("/usr/local/bin/brew")
    sh %(ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")
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
end

namespace :submodule do
  desc "Install submodules"
  task :init do
    sh %(git submodule update --init)
  end

  desc "Update submodules"
  task :update do
    Dir.chdir(File.join(Dir.pwd, ".vim", "bundle", "neobundle.vim"))
    sh %(git pull origin master)
  end
end

private

def anyenv
  File.join(ANYENV_DIR, "bin", "anyenv")
end

def clone_from_github(repository, target_dir)
  sh %(git clone --recursive https://github.com/#{repository}.git #{target_dir})
end

def env_installed?(env)
  `#{anyenv} envs`.split("\n").include?(env)
end

def install_env(env)
  sh %(#{anyenv} install #{env}) unless env_installed?(env)
end
