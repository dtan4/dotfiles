SYMLINKS_EXCLUDE = %w(. .. .git .gitmodules Rakefile .xinitrc README.md)
LINUX_ONLY = %w(.conkyrc .Xresources)
MAC_ONLY = %w(.tmux-Darwin.conf)

task default: "update"

desc "Install dotfiles"
task :install => [
                  :init_submodules,
                  :create_symlinks
                 ] do
end

desc "Update dotfiles"
task :update => [
                 :update_submodules,
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
    destination = File.join(ENV["HOME"], file)

    next if File.exists?(destination) || Dir.exists?(destination)

    ln_s(source, destination)
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
