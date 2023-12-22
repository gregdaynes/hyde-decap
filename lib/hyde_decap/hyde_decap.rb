require 'jekyll'
require 'yaml'
require 'open3'
require_relative 'generated_file.rb'

module Jekyll
  class HydeDecapGenerator < Generator
    def generate(site)
      Hyde::Decap.new(site).generate()
    end
  end

  module Commands
    class Decap < Command
      class << self
        # command options should mirror from `jekyll serve`
        COMMAND_OPTIONS = {
          "ssl_cert"             => ["--ssl-cert [CERT]", "X.509 (SSL) certificate."],
          "host"                 => ["host", "-H", "--host [HOST]", "Host to bind to"],
          "open_url"             => ["-o", "--open-url", "Launch your site in a browser"],
          "detach"               => ["-B", "--detach",
                                     "Run the server in the background",],
          "ssl_key"              => ["--ssl-key [KEY]", "X.509 (SSL) Private Key."],
          "port"                 => ["-P", "--port [PORT]", "Port to listen on"],
          "show_dir_listing"     => ["--show-dir-listing",
                                     "Show a directory listing instead of loading " \
                                     "your index file.",],
          "skip_initial_build"   => ["skip_initial_build", "--skip-initial-build",
                                     "Skips the initial site build which occurs before " \
                                     "the server is started.",],
          "livereload"           => ["-l", "--livereload",
                                     "Use LiveReload to automatically refresh browsers",],
          "livereload_ignore"    => ["--livereload-ignore ignore GLOB1[,GLOB2[,...]]",
                                     Array,
                                     "Files for LiveReload to ignore. " \
                                     "Remember to quote the values so your shell " \
                                     "won't expand them",],
          "livereload_min_delay" => ["--livereload-min-delay [SECONDS]",
                                     "Minimum reload delay",],
          "livereload_max_delay" => ["--livereload-max-delay [SECONDS]",
                                     "Maximum reload delay",],
          "livereload_port"      => ["--livereload-port [PORT]", Integer,
                                     "Port for LiveReload to listen on",],
        }.freeze

        LIVERELOAD_PORT = 35_729
        LIVERELOAD_DIR = File.join(__dir__, "serve", "livereload_assets")

        def init_with_program(prog)
          prog.command(:decap) do |c|
            c.description "Serve your site locally while running Decap CMS"
            c.syntax "decap [options]"
            c.alias :decap
            c.alias :d

            COMMAND_OPTIONS.each do |key, val|
              c.option key, *val
            end

            c.action do |args, options|
              # need to convert options to flags
              flags = options.map do |key, value|
                if value == true
                  "--#{key}"
                else
                  "--#{key} #{value}"
                end
              end

              # TODO replace netlify-cms-proxy-server with decap version when released
              cmd = "trap 'kill %1; kill %2; exit;' SIGINT SIGTERM;"
              cmd += " jekyll serve #{flags.join(' ')} & npx netlify-cms-proxy-server"

              begin
                Hyde::Utils::Subprocess.new cmd do |stdout, stderr, thread|
                  unless stdout.nil?
                    stdout_filtered = stdout.inspect.gsub('"\e[32m', '').gsub('\e[39m', '').gsub('\n"', '').chomp

                    if stdout_filtered.start_with?("info")
                      Jekyll.logger.info "Decap CMS:", stdout_filtered
                    else
                      puts stdout
                    end
                  end
                  puts stderr unless stderr.nil?
                end
              rescue => e
                puts e
              end
            end
          end
        end
      end
    end
  end
end

module Hyde
  class Decap
    @@config = {
      "file_output_path" => 'admin',
      "enable" => true,
      "keep_files" => true
    }

    def initialize(site)
      @site = site
      @config = site.config.dig('hyde_decap')

      @config = @@config.merge(@site.config.dig('hyde_decap') || {})

      if config('keep_files') == true
        @site.config['keep_files'].push(config('file_output_path'))
      end

      if site.config.dig('hyde_decap').nil?
        @site.config['hyde_decap'] = @config
      end
    end

    def generate
      return unless config('enable') == true

      # create new index.html file
      html_file = Hyde::GeneratedFile.new(@site, config('file_output_path'), 'index.html')
      html_file.file_contents = File.read(File.join(File.dirname(__FILE__), 'index.html'))
      @site.static_files << html_file

      # create new config.yml file
      config_file = Hyde::GeneratedFile.new(@site, config('file_output_path'), 'config.yml')
      config_file.file_contents = @config.to_yaml
      @site.static_files << config_file
    end

    private

    def config(*keys)
      @config.dig(*keys)
    end
  end

  # copied from http://stackoverflow.com/a/1162850/83386
  # credit to [ehsanul](https://stackoverflow.com/users/127219/ehsanul)
  # and [funroll](https://stackoverflow.com/users/878969/funroll)
  module Utils
    class Subprocess
      def initialize(cmd, &block)
        Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
          trap("INT") {
            Jekyll.logger.info "Decap:", "shutting down server and Decap CMS Proxy"
            thread.exit
          }

          # read each stream from a new thread
          { :out => stdout, :err => stderr }.each do |key, stream|
            Thread.new do
              begin
                until (line = stream.gets).nil? do
                  # yield the block depending on the stream
                  if key == :out
                    yield line, nil, thread if block_given?
                  else
                    yield nil, line, thread if block_given?
                  end
                end
              rescue IOError => e
                if e.message != 'stream closed in another thread'
                  raise e
                end
              end
            end
          end

          thread.join # don't exit until the external process is done
        end
      end
    end
  end
end
