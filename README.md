# transcode-video with Intel QuickSync for Synology NAS.
## Usage
```
docker run --privileged --device="/dev/dri:/dev/dri"  -itv "$(pwd)":/data jaromirrivera/transcode-video-quicksync:v1.0
```
You can also place this in a script for automation. See transcode-video.sh for an example.