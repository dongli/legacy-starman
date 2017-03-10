module STARMAN
  class BintrayAdapter
    extend System::Command

    API_URL = 'https://api.bintray.com'
    REPO = 'precompiled'

    def self.init
      @@user = ConfigStore.config[:storage][:bintray][:username] rescue nil
      @@api_key = ConfigStore.config[:storage][:bintray][:api_key] rescue nil
    end

    def self.check_connection
      true
    end

    def self.auth options
      options[:username] = @@user
      options[:password] = @@api_key
      options
    end

    def self.uploaded? package
      tar_name = Storage.tar_name package
      url = "https://bintray.com/starman/#{REPO}/download_file?file_path=#{tar_name}"
      url_exist? url
    end

    def self.upload! package
      tar_name = Storage.tar_name package
      # Compress built package.
      CLI.report_notice "Compress package #{CLI.blue package.name}."
      compress package.prefix, "#{ConfigStore.package_root}/#{tar_name}"
      # Upload to Bintray.
      CLI.report_notice "Upload package #{CLI.blue package.name}."
      create_package package if not package_exist? package
      delete_version package if version_exist? package
      create_version package
      curl API_URL + "/content/starman/#{REPO}/#{package.name}/#{tar_name}/#{tar_name}?publish=1",
        "#{ConfigStore.package_root}/#{tar_name}",
        auth(method: :put, content_type: :octet_stream, multipart: true)
    end

    def self.delete! package
      tar_name = Storage.tar_name package
      curl API_URL + "/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}", nil, auth(method: :delete)
    end

    def self.download package
      tar_name = Storage.tar_name package
      url = "https://bintray.com/starman/#{REPO}/download_file?file_path=#{tar_name}"
      curl url, ConfigStore.package_root, rename: tar_name
    end

    private

    def self.create_package package
      payload = {
        name: package.name,
        desc: "Precompiled package for #{package.name} created by STARMAN.",
        licenses: [ 'Unlicense' ],
        vcs_url: 'None'
      }.to_json
      curl API_URL + "/packages/starman/#{REPO}", nil, auth(method: :post, content_type: :json, payload: payload)
    end

    def self.delete_package package
      curl API_URL + "/packages/starman/#{REPO}/#{package.name}", nil, auth(method: :delete)
    end

    def self.package_exist? package
      url_exist? API_URL + "/packages/starman/#{REPO}/#{package.name}"
    end

    def self.create_version package
      tar_name = Storage.tar_name package
      payload = { name: tar_name, released: Time.now.utc.iso8601 }.to_json
      curl API_URL + "/packages/starman/#{REPO}/#{package.name}/versions", nil,
        auth(method: :post, content_type: :json, payload: payload)
    end

    def self.delete_version package
      tar_name = Storage.tar_name package
      curl API_URL + "/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}", nil, auth(method: :delete)
    end

    def self.version_exist? package
      tar_name = Storage.tar_name package
      url_exist? API_URL + "/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}"
    end
  end
end
