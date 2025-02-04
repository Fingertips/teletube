require "json"

module Teletube
  class Client
    def initialize(config : Teletube::Config, context : Teletube::Context)
      @config = config
      @context = context
      @http = Teletube::Http.new(@config)
    end

    def create_artwork
      handle_response(@http.post(path: "/api/v1/uploads/#{@context.params["upload_id"]}/artwork"))
    end

    def get_categories
      handle_response(@http.get(path: "/api/v1/categories"))
    end

    def get_channels
      if @context.params.empty?
        handle_response(@http.get(path: "/api/v1/channels"))
      else
        handle_response(@http.get(path: "/api/v1/channels", params: @context.params))
      end
    end

    def create_channel
      handle_response(@http.post(path: "/api/v1/channels", params: @context.params))
    end

    def get_channel
      handle_response(@http.get(path: "/api/v1/channels/#{@context.params["id"]}"))
    end

    def update_channel
      handle_response(
        @http.patch(path: "/api/v1/channels/#{@context.params["id"]}", params: @context.params)
      )
    end

    def destroy_channel
      handle_response(
        @http.delete(path: "/api/v1/channels/#{@context.params["id"]}")
      )
    end

    class Upload
      # 50 megabytes
      SEGMENT_SIZE = 52428800

      property http : Teletube::Http
      property filename : String
      property location : String

      def initialize(http, filename)
        @http = http
        @filename = filename
        @location = ""
      end

      def id
        path.split("/").last
      end

      def path
        "/" + location.split("/")[3..-1].join("/")
      end

      def perform
        create_file
        upload_file
      end

      def create_file
        headers = self.class.headers
        headers["Upload-Length"] = File.size(filename).to_s
        if @filename
          name = @filename.split("/").last
          headers["Upload-Metadata"] = "filename #{Base64.strict_encode(name)}"
        end
        response = handle_response(http.post(path: "/files", headers: headers))
        if response.status_code >= 200 && response.status_code < 300
          @location = response.headers["Location"]
          STDERR.puts "📃 #{id}"
        end
        response
      end

      def get_upload_offset
        offset = -1
        while (offset < 0)
          response = handle_response(http.head(path: path, headers: self.class.headers))
          if response.status_code == 200
            offset = response.headers["Upload-Offset"].to_i
          elsif response.status_code == 423
            sleep(1.second)
          end
        end
        offset
      end

      def upload_file
        response = nil
        offset = 0
        headers = self.class.headers
        segment = Bytes.new(SEGMENT_SIZE)
        File.open(filename, "rb") do |file|
          while (size = file.read(segment)) > 0
            headers["Content-Type"] = "application/offset+octet-stream"
            headers["Upload-Offset"] = offset.to_s
            response = handle_response(http.patch(path: path, headers: headers, body: segment[0, size]))
            if response.status_code >= 200 && response.status_code < 300
              offset += segment.size
            elsif [502, 503].includes?(response.status_code)
              @http.reset
              offset = get_upload_offset
              file.pos = offset
              STDERR.puts "🗑 resetting offset to #{offset}"
            else
              break
            end
          end
        end
        response
      end

      def handle_response(response)
        STDERR.puts "⚡️ #{response.status} (#{response.status_code})"
        puts response.body unless response.body.blank?
        response
      end

      def self.headers
        headers = HTTP::Headers.new
        headers["Tus-Resumable"] = "1.0.0"
        headers
      end
    end

    # Only creates a new file on tusd. Could technically be useful when you want to use a different
    # client to actually upload the file.
    def create_file
      return unless @context.filename

      upload = Upload.new(@http, @context.filename || "")
      upload.create_file
    end

    def upload_file
      return unless @context.filename

      upload = Upload.new(@http, @context.filename || "")
      upload.perform
      @context.params["filename"] =
        @context.params["upload_id"] = JSON::Any.new(upload.id)
    end

    def get_files
      handle_response(@http.get(path: "/api/v1/videos/#{@context.params["video_id"]}/files"))
    end

    def download_file
      response = @http.get(path: "/api/v1/videos/#{@context.params["video_id"]}/files")
      STDERR.puts "⚡️ #{response.status} (#{response.status_code})"
      if response.status_code == 200
        files = JSON.parse(response.body).as_a
        if files.empty?
          puts "🙁 The video does not have any files."
        else
          filename = files[0]["filename"] ? files[0]["filename"].as_s : "original.mov"
          File.open(filename, "w") do |file|
            HTTP::Client.get(files[0]["url"].as_s) do |response|
              IO.copy(response.body_io, file)
            end
          end
        end
      end
    end

    def get_videos
      handle_response(@http.get(path: "/api/v1/channels/#{@context.params["channel_id"]}/videos"))
    end

    def create_video
      upload_file
      handle_response(@http.post(path: "/api/v1/videos", params: @context.params))
    end

    def get_video
      handle_response(@http.get(path: "/api/v1/videos/#{@context.params["id"]}"))
    end

    def update_video
      handle_response(
        @http.patch(path: "/api/v1/videos/#{@context.params["id"]}", params: @context.params)
      )
    end

    def destroy_video
      handle_response(@http.delete(path: "/api/v1/videos/#{@context.params["id"]}"))
    end

    def get_documents
      if @context.params.has_key?("video_id")
        handle_response(@http.get(path: "/api/v1/videos/#{@context.params["video_id"]}/documents"))
      elsif @context.params.has_key?("channel_id")
        handle_response(@http.get(path: "/api/v1/channels/#{@context.params["channel_id"]}/documents"))
      end
    end

    def create_document
      upload_file
      handle_response(@http.post(path: "/api/v1/documents", params: @context.params))
    end

    def create_avatar
      upload_file
      handle_response(@http.post(path: "/api/v1/avatars", params: @context.params))
    end

    def destroy_avatars
      handle_response(@http.delete(path: "/api/v1/avatars"))
    end

    def destroy_document
      handle_response(@http.delete(path: "/api/v1/documents/#{@context.params["id"]}"))
    end

    def get_languages
      handle_response(@http.get(path: "/api/v1/languages"))
    end

    def get_profile
      handle_response(@http.get(path: "/api/v1/profiles/#{@context.params["id"]}"))
    end

    def get_profiles_me
      handle_response(@http.get(path: "/api/v1/profiles/me"))
    end

    def get_video_progress
      handle_response(@http.get(path: "/api/v1/videos/#{@context.params["video_id"]}/progress"))
    end

    def get_trash
      handle_response(@http.get(path: "/api/v1/trash"))
    end

    def create_restoration
      handle_response(
        @http.post(path: "/api/v1/#{@context.params["type"]}/#{@context.params["id"]}/restorations")
      )
    end

    def get_browsable_channels
      handle_response(@http.get(path: "/api/v1/browse/channels"))
    end

    def get_browsable_channel
      handle_response(@http.get(path: "/api/v1/browse/channels/#{@context.params["id"]}"))
    end

    def get_browsable_videos
      handle_response(@http.get(path: "/api/v1/browse/channels/#{@context.params["channel_id"]}/videos"))
    end

    def get_browsable_video
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["id"]}"))
    end

    def get_browsable_artwork
      handle_response(@http.get(path: "/api/v1/browse/channels/#{@context.params["channel_id"]}/artwork"))
    end

    def get_browsable_video_variants
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/video_variants"))
    end

    def get_browsable_poster
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/poster"))
    end

    def get_browsable_audio_variants
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/audio_variants"))
    end

    def get_browsable_waveform
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/waveform"))
    end

    def get_browsable_chapter_markers
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/chapter_markers"))
    end

    def get_browsable_text_tracks
      handle_response(@http.get(path: "/api/v1/browse/videos/#{@context.params["video_id"]}/text_tracks"))
    end

    def get_browsable_text_track
      response = get_browsable_text_tracks
      if response.status_code == 200
        text_tracks = JSON.parse(response.body).as_a
        text_tracks.each do |text_track|
          if @context.params.has_key?("language")
            if @context.params["language"].as_s == text_track["language"].as_s
              print_browsable_text_track(text_track)
              return
            end
          else
            print_browsable_text_track(text_track)
            return
          end
        end
      end
    end

    def print_browsable_text_track(text_track)
      path = text_track["#{@context.params["format"]}_path"].as_s
      response = handle_response(@http.get(path: path))
      if response.status_code == 200
        puts response.body
      end
    end

    def handle_response(response)
      STDERR.puts "⚡️ #{response.status} (#{response.status_code})"
      puts response.body unless response.body.blank?
      response
    end
  end
end
