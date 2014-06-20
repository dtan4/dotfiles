SYMLINKS_EXCLUDE = %w(. .. .git .gitmodules Rakefile .xinitrc README.md default-gems)
LINUX_ONLY = %w(.conkyrc .Xresources)
MAC_ONLY = %w(.tmux-Darwin.conf)

ANYENV_DIR = File.join(ENV["HOME"], ".anyenv")

RBENV_PLUGINS = {
                 "gem-src" => "amatsuda/gem-src.git",
                 "rbenv-default-gems" => "sstephenson/rbenv-default-gems",
                 "rbenv-gem-rehash" => "sstephenson/rbenv-gem-rehash",
                }

task default: "update"

desc "Install dotfiles"
task :install => [
                  :init_submodules,
                  :install_anyenv,
                  :create_symlinks
                 ] do
end

desc "Update dotfiles"
task :update => [
                 :update_submodules,
                 :install_rbenv_plugins,
                 :create_symlinks
                ] do
end

desc "Create symlinks"
task :create_symlinks do
  uname = `uname`.strip

  Dir.glob("*", File::FNM_DOTMATCH) do |file|
    next if SYMLINKS_EXCLUDE.include?(file)
    next if (uname != "Darwin") && MAC_ONLY.include?(file)
    next if (uname != "Linux") && LINUX_ONLY.include?(file)

    source = File.join(Dir.pwd, file)
    target = File.join(ENV["HOME"], file)

    next if File.exists?(target) || Dir.exists?(target)

    ln_s(source, target)
  end
end

desc "Install submodules"
task :init_submodules do
  sh %(git submodule update --init)
end

desc "Update submodules"
task :update_submodules do
  sh %(git submodule update)
end

desc "Install anyenv"
task :install_anyenv do
  unless Dir.exists?(ANYENV_DIR)
    clone_from_github("riywo/anyenv", ANYENV_DIR)
    sh %(exec $SHELL -l)
  end

  %w(rbenv plenv ndenv).each do |env|
    Rake::Task["install_#{env}"].invoke
  end
end

desc "Install ndenv"
task :install_ndenv do
  install_env("ndenv")
end

desc "Install plenv"
task :install_plenv do
  install_env("plenv")
end

desc "Install rbenv"
task :install_rbenv do
  install_env("rbenv")
  Rake::Task["install_rbenv_plugins"].invoke
end

desc "Install rbenv plugins"
task :install_rbenv_plugins do
  RBENV_PLUGINS.each do |plugin, repository|
    plugin_dir = File.join(ANYENV_DIR, "envs", "rbenv", "plugins", plugin)
    next if Dir.exists?(plugin_dir)

    clone_from_github(repository, plugin_dir)
  end

  source = File.join(Dir.pwd, "default-gems")
  target = File.join(ANYENV_DIR, "envs", "rbenv", "default-gems")

  ln_s(source, target) unless File.exist?(target)
end

private

def clone_from_github(repository, target_dir)
  sh %(git clone --recursive https://github.com/#{repository} #{target_dir})
end

def env_installed?(env)
  `anyenv envs`.split("\n").include?(env)
end

def install_env(env)
  sh %(anyenv install #{env}) unless env_installed?(env)
end
