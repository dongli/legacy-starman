module STARMAN
  class BintrayAdapter
    extend System::Command

    API_URL = 'https://api.bintray.com'
    REPO = 'precompiled'

    def self.init
      @@user = ENV['STARMAN_BINTRAY_USER']
      @@api_key = ENV['STARMAN_BINTRAY_API_KEY']
      if @@user and @@api_key
        begin
          require 'rest-client'
          @@client = RestClient::Resource.new(API_URL, user: @@user, password: @@api_key)
        rescue LoadError
          PACKMAN.report_warning 'rest-client is not installed!'
        end
      end
    end

    def self.check_connection
      true
    end

    def self.uploaded? package
      tar_name = Storage.tar_name package
      @@client["/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}"].get do |resp, req, res, &b|
        resp.code == 200
      end
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
      @@client["/content/starman/#{REPO}/#{package.name}/#{tar_name}/#{tar_name};publish=1"].put(
        File.new("#{ConfigStore.package_root}/#{tar_name}"),  content_type: 'application/octet-stream', multipart: true) do |resp, req, res, &b|
        CLI.report_error "Failed to upload package #{CLI.blue name} to Bintray!" if resp.code != 201
      end
    end

    def self.delete! package
      tar_name = Storage.tar_name package
      @@client["/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}"].delete do |resp, req, res, &b|
        CLI.report_error "Failed to delete #{STARMAN.blue tar_name} due to #{STARMAN.red res.message}!" if resp.code != 200
      end
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
      @@client["/packages/starman/#{REPO}"].post(payload, content_type: :json) do |resp, req, res|
        CLI.report_error "Failed to create #{CLI.blue package.name} due to #{CLI.red res.message}!" if resp.code != 201
      end
    end

    def self.delete_package package
      @@client["/packages/starman/#{REPO}/#{package.name}"].delete do |resp, req, res|
        CLI.report_error "Failed to delete #{CLI.blue package.name} due to #{CLI.red res.message}!" if resp.code != 200
      end
    end

    def self.package_exist? package
      @@client["/packages/starman/#{REPO}/#{package.name}"].get do |resp, req, res|
        resp.code == 200
      end
    end

    def self.create_version package
      tar_name = Storage.tar_name package
      payload = { name: tar_name, released: Time.now.utc.iso8601 }.to_json
      @@client["/packages/starman/#{REPO}/#{package.name}/versions"].post(payload, content_type: :json) do |resp, req, res|
        CLI.report_error "Failed to create this version due to #{CLI.red res.message}!" if resp.code != 201
      end
    end

    def self.delete_version package
      tar_name = Storage.tar_name package
      @@client["/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}"].delete do |resp, req, res|
        CLI.report_error "Failed to delete this version due to #{CLI.red res.message}!" if resp.code != 200
      end
    end

    def self.version_exist? package
      tar_name = Storage.tar_name package
      @@client["/packages/starman/#{REPO}/#{package.name}/versions/#{tar_name}"].get do |resp, req, res|
        resp.code == 200
    	end
    end
  end
end
