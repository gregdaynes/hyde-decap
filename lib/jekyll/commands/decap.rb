# frozen_string_literal: true

module Jekyll
  module Commands
    class Decap < Command
      class << self
        # command options should mirror from `jekyll serve`
        COMMAND_OPTIONS = {
          "ssl_cert" => ["--ssl-cert [CERT]", "X.509 (SSL) certificate."],
          "host" => ["host", "-H", "--host [HOST]", "Host to bind to"],
          "open_url" => ["-o", "--open-url", "Launch your site in a browser"],
          "detach" => ["-B", "--detach",
            "Run the server in the background"],
          "ssl_key" => ["--ssl-key [KEY]", "X.509 (SSL) Private Key."],
          "port" => ["-P", "--port [PORT]", "Port to listen on"],
          "show_dir_listing" => ["--show-dir-listing",
            "Show a directory listing instead of loading " \
            "your index file."],
          "skip_initial_build" => ["skip_initial_build", "--skip-initial-build",
            "Skips the initial site build which occurs before " \
            "the server is started."],
          "livereload" => ["-l", "--livereload",
            "Use LiveReload to automatically refresh browsers"],
          "livereload_ignore" => ["--livereload-ignore ignore GLOB1[,GLOB2[,...]]",
            Array,
            "Files for LiveReload to ignore. " \
            "Remember to quote the values so your shell " \
            "won't expand them"],
          "livereload_min_delay" => ["--livereload-min-delay [SECONDS]",
            "Minimum reload delay"],
          "livereload_max_delay" => ["--livereload-max-delay [SECONDS]",
            "Maximum reload delay"],
          "livereload_port" => ["--livereload-port [PORT]", Integer,
            "Port for LiveReload to listen on"]
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
              cmd += " jekyll serve #{flags.join(" ")} & npx netlify-cms-proxy-server"

              begin
                Hyde::Decap::Subprocess.new cmd do |stdout, stderr, thread|
                  unless stdout.nil?
                    stdout_filtered = stdout.inspect.gsub('"\e[32m', "").gsub('\e[39m', "").gsub('\n"', "").chomp

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
