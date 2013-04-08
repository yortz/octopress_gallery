require 'mini_magick'

module Jekyll
  module JekyllMinimagick

   class GeneratedImageFile < Jekyll::StaticFile
     # Initialize a new GeneratedImage.
     #   +site+ is the Site
     #   +base+ is the String path to the <source>
     #   +dir+ is the String path between <source> and the file
     #   +name+ is the String filename of the file
     #   +preset+ is the Preset hash from the config.
     #
     # Returns <GeneratedImageFile>
     def initialize(site, base, dir, name, preset)
       @site = site
       @base = base
       @dir  = dir
       @name = name
       @dst_dir = preset.delete('destination')
       @src_dir = preset.delete('source')
       @commands = preset
     end

     # Obtains source file path by substituting the preset's source directory
     # for the destination directory.
     #
     # Returns source file path.
     # "/Users/name/code/projects/domain.com/source/_galleries/gallery_name/image_1.jpg"
     def path
       File.join(@base, @dir.sub(@dst_dir, @src_dir), @name)
     end

     # Use MiniMagick to create a derivative image at the destination
     # specified (if the original is modified).
     #   +dest+ is the String path to the destination dir
     #
     # Returns false if the file was not modified since last time (no-op).
     def write(dest)
       dest_path = destination("source")

       # return false if
       #"/Users/name/code/projects/domain.com/source/_assets/images/galleries/gallery_name/medium/image_1.jpg"
       # or thumbs don't exist

       unless File.exist? dest_path #and modified?

         @@mtimes[path] = mtime

         FileUtils.mkdir_p(File.dirname(dest_path))
         image = ::MiniMagick::Image.open(path)

         @commands.each_pair do |command, arg|
           image.combine_options do |c|
              arg.each do |option|
                  option.each {|command, value| c.send command,value}
              end
           end
         end

         image.write dest_path
         puts "Writing to #{dest_path}\n\n"

         if @site.config["assets"]
           asset_path = dest_path.gsub(/(\A\S*)(\/images)(\/)/, "")
           Jekyll::AssetsPlugin::AssetFile.new(@site, @site.assets[asset_path]).write "public/#{@dest}"
         end
       end

     end
   end

   class MiniMagickGenerator < Generator
     safe true
     priority :highest

     # Find all image files in the source directories of the presets specified
     # in the site config.  Add a GeneratedImageFile to the static_files stack
     # for later processing.
     def generate(site)
       return unless site.config['mini_magick']

       site.config['mini_magick'].each_pair do |name, preset|
         #this is needed to avoid Dir.glob discrepancy
         #http://stackoverflow.com/questions/6220753/does-dir-glob-guarantee-the-order
         list = Dir.glob(File.join(site.source, preset['source'], "*.{png,jpg,jpeg,gif}"))
         list.sort.each do |source|
           site.static_files << GeneratedImageFile.new(site, site.source, preset['destination'], File.basename(source), preset.clone)
         end
       end
     end
   end

  end
end
