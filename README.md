# transcode-video with Intel QuickSync for Synology NAS.
## Usage
```
docker run --privileged --device="/dev/dri:/dev/dri"  -itv "$(pwd)":/data jaromirrivera/transcode-video-quicksync:v1.0
```
You can also place this in a script for automation. See transcode-video.sh for an example.

## Scripts

**transcode-video-batch** 

This script can be run in a directory containing video files you would like to transcode. Transcoded files will be placed in a directory called output/ created in the directory from with which this script is called from.

**transcode-video**

This script can be called to run one line transcode jobs. Great for testing.