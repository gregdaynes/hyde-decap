module Jekyll
  class HydeDecapGenerator < Generator
    def generate(site)
      Hyde::Decap::Generator.new(site).generate
    end
  end
end
