module STARMAN
  module Utils
    def sha_same? file_path, expect
      if File.file? file_path
        expect.eql? Digest::SHA256.hexdigest(File.read(file_path))
      elsif File.directory? file_path
        tmp = []
        Dir.glob("#{file_path}/**/*").each do |file|
          next if File.directory? file
          tmp << Digest::SHA256.hexdigest(File.read(file))
        end
        current = Digest::SHA256.hexdigest(tmp.sort.join)
        if expect.eql? current
          return true
        else
          CLI.report_warning "Directory #{file_path} SHA256 is #{current}."
          return false
        end
      else
        CLI.report_error "Unknown file type \"#{file_path}\"!"
      end
    end

    def symbolize_keys hash
      hash = hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.is_a?(Hash) ? symbolize_keys(v) : v }
    end

    def stringfy_keys hash
      hash = hash.inject({}) { |memo, (k,v)| memo[k.to_s] = v; memo }
    end
  end
end
