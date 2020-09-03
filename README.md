# nginx-rtmps
Docker image for Nginx + Stunnel to enable streaming to multiple RTMP(S) services. This was created to allow OBS Streaming to multiple services, including Facebook which requires RTMPS.

# Quick Start
The image requires the following environment variables to be set.

* STREAMS - space separated list of RTMP(S) URLs. 
```
STREAMS="rtmp://a.rtmp.youtube.com/live2/[put_your_key_here] rtmps://live-api-s.facebook.com:443/rtmp/[put_your_key_here]" 
"
```

* LOCAL_STREAM - name of the local stream that OBS will point to. This value is arbitrary and you just need to ensure that this name matches what you entered into OBS.
```
LOCAL_STREAM=[name_of_your_local_stream]
```

## Run the container
Map the container's port 1935 to a port on your server.
```
docker run -p 1975:1975
```

## OBS Setup
In Settings/Stream, set the server to:
```
rtmp://[your container IP address]:[port]/[name_of_your_local_stream]
```
