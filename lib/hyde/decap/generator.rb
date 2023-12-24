module Hyde
  module Decap
    class Generator
      @@config = {
        "file_output_path" => "/admin",
        "enable" => true,
        "keep_files" => true
      }

      def initialize(site)
        @site = site
        @config = site.config.dig("hyde_decap")

        @config = @@config.merge(@site.config.dig("hyde_decap") || {})

        # compatibility with jekyll-sitemap
        # set the admin path to ignore
        @site.config["defaults"].push({
          "scope" => {
            "path" => "admin/index.html"
          },
          "values" => {
            "sitemap" => false
          }
        })

        if config("keep_files") == true
          @site.config["keep_files"].push(config("file_output_path"))
        end

        if site.config.dig("hyde_decap").nil?
          @site.config["hyde_decap"] = @config
        end
      end

      def generate
        return unless config("enable") == true

        # create new index.html file
        html_file = Hyde::Decap::GeneratedFile.new(@site, config("file_output_path"), "index.html")
        html_file.file_contents = File.read(File.join(File.dirname(__FILE__), "index.html"))
        @site.static_files << html_file

        # create new config.yml file
        config_file = Hyde::Decap::GeneratedFile.new(@site, config("file_output_path"), "config.yml")
        config_file.file_contents = @config.to_yaml
        @site.static_files << config_file
      end

      private

      def config(*)
        @config.dig(*)
      end
    end
  end
end
