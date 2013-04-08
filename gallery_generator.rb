require 'jekyll'
require 'json'

module Jekyll
  class ImageData < StaticFile
    def write(dest)
      begin
        super(dest)
      rescue
      end
      true
    end
  end

  class GalleriesJsonGenerator < Generator

    def generate(site=Jekyll::Site.new(YAML.load_file("_config.yml")))
      path = "public/assets/galleries"
      get_assets_for(path)
      create_json_for(site, @assets)
    end
  
    def get_assets_for(path)
      galleries = Dir[File.join("#{path}/**")]
      @assets = []
      galleries.each do |g|
        @assets << { gallery: { name: g.gsub(/(\A\w*\/)(\w*\/)(\w*\/)/ , "")} }
        Dir[File.join("#{g}/**")].each do |s|
          type = s.gsub(/(\A\w*\/)(\w*\/)(\w*\/)(\w*\/)/, "")
          @assets.each do |a|
            name = a[:gallery][:name]
            images = Dir[File.join("#{path}/#{name}/#{type}/**")].map {|i| i.gsub(/\A\w*\//, "")}
            a[:gallery][:"#{type}"] = images if !images.empty?
          end
        end
      end
    end

    def create_json_for(site, assets)
      file = File.new(File.join(site.dest, "galleries.json"), "w")
      file.write(JSON.pretty_generate(assets))
      file.close
      site.static_files << Jekyll::ImageData.new(site, site.dest, "/", "galleries.json")
    end
  end
  
end

