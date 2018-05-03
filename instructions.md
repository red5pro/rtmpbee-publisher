# Convert from AVI to FLV

```sh
$ ffmpeg -i big_buck_bunny_480p_surround-fix.avi -y -ab 56k -ar 44100 -b:a 54k -b:v 750k -r 24 -f flv output.flv
```

# Streaming

```sh
$ ffmpeg -re -stream_loop -1 -fflags +genpts -i output.flv -c copy -f flv rtmp://10.0.0.10:1935/live/stream1todd
```
