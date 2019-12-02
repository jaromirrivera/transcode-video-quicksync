#!/usr/bin/env ruby

supported_types = %w(mov flv wmv avi divx mpg mpeg mp4 mkv)
output_dir = "./output"
docker_command = "docker run --rm --privileged --device=\"/dev/dri:/dev/dri\" -itv \"`pwd`\":/data --name transcode-video jaromirrivera/transcode-video-quicksync:v1.1"

glob = "./*\.{#{supported_types.join(',')}}"

if Dir.glob(glob).length > 0
  # Make the output dir
  system("mkdir -p #{output_dir}")
  # Pull the latest docker image
  # system("docker pull ntodd/video-transcoding")
else
  puts "No supported video types in directory. Supported types: #{supported_types.join(', ')}"
end

Dir.glob(glob).each do |input_path|
  output_path = "#{output_dir}/#{File.basename(input_path, '.*')}.mp4"
  transcode_command = "transcode-video --crop detect --fallback-crop minimal --handbrake-option encoder=qsv_h265 --target small --abr --audio-width all=surround --ac3-bitrate 384 --pass-ac3-bitrate 384 --mp4 \"#{input_path}\" -o \"#{output_path}\""
  command = "#{docker_command} #{transcode_command}"

  begin
    IO.popen(command, err: [:child, :out]) do |io|
      Signal.trap 'INT' do
        Process.kill 'INT', io.pid
      end

      io.each_char do |char|
        print char
      end
    end
  rescue SystemCallError => error
    raise "transcoding failed: #{error}"
  end
end

