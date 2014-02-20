SYMLINKS_EXCLUDE = %w{. .. .git .gitmodules Rakefile .xinitrc}

task default: "setup:setup"

namespace :setup do
  desc "Set up this computer to use the dotfiles"
  task :setup do
    Rake::Task["setup:symlink_dotfiles"].invoke
    # Rake::Task["setup:update_submodules"].invoke
  end

  desc "Make symlinks from home directory to the dotfiles"
  task :symlink_dotfiles do
    Dir.glob("*", File::FNM_DOTMATCH) do |file|
      unless SYMLINKS_EXCLUDE.include? file
        source = File.join(Dir.pwd, file)
        destination = File.expand_path("~/#{file}")
        ln_s(source, destination) unless File.exists? destination
      end
    end
  end

  # desc "Update git submodules"
  # task :update_submodules do
  #   sh "git submodule update --init"
  # end
end
