module STARMAN
  module Command
    class Edit
      def self.accepted_options
        {}
      end

      def self.run
        editor = 'vim'
        system "#{editor} #{ENV['STARMAN_ROOT']}/packages/#{CommandLine.direct_packages.map { |x| "#{x}.rb" }.join}"
      end
    end
  end
end
