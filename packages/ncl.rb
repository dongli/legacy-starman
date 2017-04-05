module STARMAN
  class Ncl < Package
    version '6.4.0'

    label :external_binary
    label :compiler_agnostic

    if OS.mac?
      depends_on :gcc
      depends_on :fontconfig
    end

    external_binary_on :mac, '>= 10.11' do
      url 'https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=1139ad88-fa02-11e6-a976-00c0f03d5b7c'
      sha256 '2e1a2957dacd14835716f0f7309117a35e1f6255fa8569d0dc3038c42df9cbfd'
      filename 'ncl_ncarg-6.4.0-MacOS_10.11_64bit_gnu610.tar.gz'
    end

    external_binary_on :centos, '=~ 6.0' do
      url 'https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=fcdc5c23-fa01-11e6-a976-00c0f03d5b7c'
      sha256 '82fd49d2a49458c783b50fcda96945949132ccab372b2694427753475059400f'
      filename 'ncl_ncarg-6.4.0-CentOS6.8_64bit_gnu447.tar.gz'
    end

    external_binary_on :centos, '>= 7.0' do
      url 'https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=191cb88a-fa02-11e6-a976-00c0f03d5b7c'
      sha256 '85620a87e626bef385d0b0c821a3de147c41fc4b8170be64d5757eb60d0695dc'
      filename 'ncl_ncarg-6.4.0-CentOS7.3_64bit_gnu485.tar.gz'
    end

    external_binary_on :ubuntu, '>= 12' do
      url 'https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c'
      sha256 'ebd7365243bf2b36ef67937333d969138ad59b17f9e637ace2b747538c5ef256'
      filename 'ncl_ncarg-6.4.0-Debian8.6_64bit_gnu492.tar.gz'
    end

    def export_env
      System::Shell.set 'NCARG_ROOT', prefix
    end

    def post_install
      # Change link path.
      if OS.mac?
        FileUtils.mkdir_p "#{persist}/lib" if not Dir.exist? "#{persist}/lib"
        ['libgomp.1.dylib', 'libstdc++.6.dylib', 'libgcc_s.1.dylib'].each do |lib|
          rm_f "#{persist}/lib/#{lib}" if File.symlink? "#{persist}/lib/#{lib}"
          ln_s "#{Gcc.lib}/gcc/#{VersionSpec.new(Gcc.version).major}/#{lib}", "#{persist}/lib"
        end
        ['libfontconfig.1.dylib'].each do |lib|
          rm_f "#{persist}/lib/#{lib}" if File.symlink? "#{persist}/lib/#{lib}"
          ln_s "#{Fontconfig.lib}/#{lib}", "#{persist}/lib"
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
