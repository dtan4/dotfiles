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

desc "Update dotfiles"
task :update => [
  "symlink"
] do
end

namespace :clean do
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
