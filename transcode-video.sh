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

#transcode_command="transcode-video --target small --abr -o \"/output/$m4v\" --handbrake-option encoder=x265 --audio-width all=surround --ac3-bitrate 384 --pass-ac3-bitrate 384 \"/input/$mkv\""

# docker run --rm \
#            --cpuset-cpus="1-2" \
#            --name handbrake \
#            -v "$(pwd)/$map:/input:ro" \
#            -v "${CONVERTED_FILE_LOCATION}:/output:rw" \
#            supercoder/docker-handbrake-cli:latest \
#            -i "/input/$mkv" \
#            -o "/output/$m4v" \
#            -e x265  -q 20.0 -r 30 --pfr  -a 1 -E faac -B 160 -6 dpl2 -R Auto \
#            -D 0.0 --audio-copy-mask aac,ac3,dtshd,dts,mp3 --audio-fallback ffac3 \
#            -f mp4 -X 1280 -Y 720 --loose-anamorphic --modulus 2 -m \
#            --x264-preset medium --h264-profile high --h264-level 3.1

