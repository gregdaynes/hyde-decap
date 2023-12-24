module Hyde
  # copied from http://stackoverflow.com/a/1162850/83386
  # credit to [ehsanul](https://stackoverflow.com/users/127219/ehsanul)
  # and [funroll](https://stackoverflow.com/users/878969/funroll)
  module Decap
    class Subprocess
      def initialize(cmd, &block)
        Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
          trap("INT") {
            Jekyll.logger.info "Decap:", "shutting down server and Decap CMS Proxy"
            thread.exit
          }

          # read each stream from a new thread
          {out: stdout, err: stderr}.each do |key, stream|
            Thread.new do
              until (line = stream.gets).nil?
                # yield the block depending on the stream
                if key == :out
                  yield line, nil, thread if block
                elsif block
                  yield nil, line, thread
                end
              end
            rescue IOError => e
              if e.message != "stream closed in another thread"
                raise e
              end
            end
          end

          thread.join # don't exit until the external process is done
        end
      end
    end
  end
end
