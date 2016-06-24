LINUX_ONLY = %w(.conkyrc .Xresources)
MAC_ONLY = %w(.tmux-Darwin.conf)

task default: "update"

desc "Clean up .vim/bundle"
task :clean => [
  "clean:symlink",
  "clean:vim_plugin"
] do
end

desc "Install dotfiles"
task :install => [
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

private

def clone_from_github(repository, target_dir)
  sh %(git clone --recursive https://github.com/#{repository}.git #{target_dir})
end

def darwin?
  uname == "Darwin"
end

def linux?
  uname == "Linux"
end

def uname
  `uname`.strip
end
