module STARMAN
  class Ncl < Package
    version '6.3.0'

    label :external_binary
    label :compiler_agnostic

    if OS.mac?
      depends_on :gcc
      depends_on :fontconfig
    end

    external_binary_on :mac, '>= 10.11' do
      url 'https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=fa161bc1-84c7-11e6-8aa0-00c0f03d5b7c'
      sha256 '69a11cef0a3d0af78a07ad7acf4769bc8f22ad3ac22d391d5223047824d1daff'
      filename 'ncl_ncarg-6.3.0.MacOS_10.11_64bit_gcc610.tar.gz'
    end

    def export_env
      System::Shell.set 'NCARG_ROOT', prefix
    end

    def post_install
      # Change link path.
      if OS.mac?
        FileUtils.mkdir_p "#{persist}/lib" if not Dir.exist? "#{persist}/lib"
        ["#{Gcc.lib}/gcc/#{VersionSpec.new(Gcc.version).major}/libgomp.1.dylib",
         "#{Gcc.lib}/gcc/#{VersionSpec.new(Gcc.version).major}/libstdc++.6.dylib",
         "#{Gcc.lib}/gcc/#{VersionSpec.new(Gcc.version).major}/libgcc_s.1.dylib",
         "#{Fontconfig.lib}/libfontconfig.1.dylib"].each do |lib|
          FileUtils.ln_s lib, "#{persist}/lib" if not File.exist? "#{persist}/lib/#{lib}"
        end
        files = ['ncl', 'ncargpath']
        files.each do |file|
          run 'install_name_tool', '-add_rpath', "#{persist}/lib", "#{Ncl.bin}/#{file}"
        end
        ['libgomp.1.dylib', 'libstdc++.6.dylib', 'libgcc_s.1.dylib', 'libfontconfig.1.dylib'].each do |lib|
          files.each do |file|
            run 'install_name_tool', '-change', "/usr/local/lib/#{lib}", "@rpath/#{lib}", "#{Ncl.bin}/#{file}"
          end
        end
      end
    end
  end
end
