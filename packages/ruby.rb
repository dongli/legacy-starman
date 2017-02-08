module STARMAN
  class Ruby < Package
    homepage 'https://www.ruby-lang.org/'
    url 'https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0.tar.gz'
    sha256 '152fd0bd15a90b4a18213448f485d4b53e9f7662e1508190aa5b702446b29e3d'
    version '2.4.0'

    def abi_version
      '2.4.0'
    end

    label :compiler_agnostic

    depends_on :gmp
    depends_on :libyaml
    depends_on :openssl
    depends_on :pkgconfig if needs_build?
    depends_on :readline
    depends_on :zlib

    def export_env
      System::Shell.prepend 'PATH', "#{persist}/bin", separator: ':', system: true
    end

    def install
      ENV.delete 'SDKROOT'
      args = %W[
        --prefix=#{prefix}
        --enable-shared
        --disable-silent-rules
        --with-sitedir=#{persist}/lib/ruby/site_ruby
        --with-vendordir=#{persist}/lib/ruby/vendor_ruby
        --with-opt-dir=#{Readline.prefix}:#{Gmp.prefix}:#{Libyaml.prefix}:#{Openssl.prefix}:#{Zlib.prefix}
      ]
      args << '--with-out-ext=tk'
      args << '--disable-install-doc'

      run './configure', *args

      # These directories are empty on install; sitedir is used for non-rubygems
      # third party libraries, and vendordir is used for packager-provided libraries.
      inreplace 'tool/rbinstall.rb' do |s|
        s.gsub! 'prepare "extension scripts", sitelibdir', ''
        s.gsub! 'prepare "extension scripts", vendorlibdir', ''
        s.gsub! 'prepare "extension objects", sitearchlibdir', ''
        s.gsub! 'prepare "extension objects", vendorarchlibdir', ''
      end

      run 'make'
      run 'make', 'install'
    end

    def post_install
      write_file "#{lib}/ruby/#{abi_version}/rubygems/defaults/operating_system.rb", rubygems_config
    end

    def rubygems_config; <<-EOT.keep_indent
      module Gem
        class << self
          alias :old_default_dir :default_dir
          alias :old_default_path :default_path
          alias :old_default_bindir :default_bindir
          alias :old_ruby :ruby
        end

        def self.default_dir
          path = [
            "#{persist}",
            "lib",
            "ruby",
            "gems",
            "#{abi_version}"
          ]

          @default_dir ||= File.join(*path)
        end

        def self.private_dir
          path = if defined? RUBY_FRAMEWORK_VERSION then
                   [
                     File.dirname(RbConfig::CONFIG['sitedir']),
                     'Gems',
                     RbConfig::CONFIG['ruby_version']
                   ]
                 elsif RbConfig::CONFIG['rubylibprefix'] then
                   [
                    RbConfig::CONFIG['rubylibprefix'],
                    'gems',
                    RbConfig::CONFIG['ruby_version']
                   ]
                 else
                   [
                     RbConfig::CONFIG['libdir'],
                     ruby_engine,
                     'gems',
                     RbConfig::CONFIG['ruby_version']
                   ]
                 end

          @private_dir ||= File.join(*path)
        end

        def self.default_path
          if Gem.user_home && File.exist?(Gem.user_home)
            [user_dir, default_dir, private_dir]
          else
            [default_dir, private_dir]
          end
      end

        def self.default_bindir
          "#{persist}/bin"
        end

        def self.ruby
          "#{bin}/ruby"
        end
      end
      EOT
    end
  end
end
