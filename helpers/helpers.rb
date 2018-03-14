module Helpers
  ENTRYPOINTS = ["main.rb", "web.rb"].freeze

  def require_files
    app_directory = File.dirname(File.expand_path(__FILE__))
    Dir.chdir(app_directory)
    Dir.glob("*rb") do |file|
      unless ENTRYPOINTS.include?(file)
        require_relative file
      end
    end
  end
end
