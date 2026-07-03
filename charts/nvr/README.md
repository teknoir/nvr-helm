# Teknoir AI NVR Helm Chart

This chart deploys Teknoir AI NVRs to a Kubernetes cluster.

> The implementation of the Helm chart is right now the bare minimum to get it to work.

## Usage in Teknoir platform
Use the HelmChart to deploy the Teknoir AI NVR to a Device.

```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nvr
  namespace: default
spec:
  repo: https://teknoir.github.io/nvr-helm
  chart: nvr
  targetNamespace: default
  valuesContent: |-
    # Example for minimal configuration
    instances:
      - name: camera-default-name
    
    # Values possible for Teknoir AI NVRs can be overridden for each instance
    defaults:
      name: camera-default-name
      camera:
        type: camera
        uri: rtsp://host:port/path
        # GST pipeline variable substitution:
        # - uri: nvr.camera.uri
        # - camera_id: release full name | fullnameOverride
        pipeline: videotestsrc ! queue ! nvvideoconvert ! video/x-raw(memory:NVMM),width=1920,height=1080 ! tee name=t t. ! nvvideoconvert ! video/x-raw(memory:NVMM),width=[1,1920],height=[1,1080],pixel-aspect-ratio=1/1 ! nvvideoconvert ! queue ! nvjpegenc quality=55 ! appsink sync=0 name=mqttsink t. ! nvvideoconvert ! video/x-raw,format=RGB,width=[1,640],height=[1,360],pixel-aspect-ratio=1/1 ! nvvideoconvert ! motioncells threshold=0.0001 gridx=32 gridy=18 ! fakesink
      # The path to the models directory
      modelRepositoryPath: /opt/teknoir/models
      # The path to the video storage
      videoStoragePath: /opt/teknoir/video/segments
      # This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
      image:
        repository: us-docker.pkg.dev/teknoir/gcr.io/nvr
        # Overrides the image tag whose default is "ds7-gst1.24.7".
        # ds7-gst1.24.7: Nvidia Ada Lovelace GPU on AMD64
        # ds7-gst1.24.7-l4t: Nvidia Orin(tegra) on ARM64
        tag: ds7-gst1.24.7
      # Set the log level for the nvr
      # - DEBUG
      # - INFO
      # - WARNING
      # - ERROR
      debugLevel: INFO
      mqtt:
        # Local MQTT broker
        broker: mqtt.kube-system
        port: 1883
        qos: 2
        keepAliveInterval: 10
        connectRetryInterval: 10
        # Topic prefix for generated topic <topicPrefix>/<camera_id: release full name | fullnameOverride>
        topicPrefix: camera/frames
        # Number of frames to queue before dropping
        queueLimit: 15
        # Send metrics collected through MQTT
        metrics: true
        metricsTopic: toe/state
        # Send events without inference calculated
        nonInferenceEvents: true
        # Send events without motion detected
        nonMotionEvents: true
      motion:
        # Number of frames to skip inference when no motion detected
        inactiveInterval: 900
        # Number of frames to skip inference when motion is detected
        activeInterval: 0
      healthz:
        fpsThreshold: 0.01
      resources:
        limits:
          cpu: 2000m
          memory: 2048Mi
        requests:
          cpu: 100m
          memory: 128Mi
      nvdsanalytics:
        enabled: false
        # Mount path for the nvdsanalytics config file: <mountPath>/config_nvdsanalytics.txt
        mountPath: /app/config
        config: |
          [property]
          enable=1
          config-width=1920
          config-height=1080
          osd-mode=2
          display-font-size=25
    
          [line-crossing-stream-0]
          enable=1
          line-crossing-Entry-0=59;591;153;557;200;688;106;426
          line-crossing-Exit-0=247;523;153;557;106;426;200;688
          line-crossing-Entry-1=1607;566;1508;550;1568;183;1448;917
          line-crossing-Exit-1=1410;534;1508;550;1448;917;1568;183
      # Deprecated in favor of ORG TREE
      location:
        country: "us"
        region: "texas"
        branch: "houston"
        facility: "office"
        site: "interior"
        zone: "test"
        group: "poc"
```

## Example values.yaml

```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nvr
  namespace: default
spec:
  repo: https://teknoir.github.io/nvr-helm
  chart: nvr
  targetNamespace: default
  valuesContent: |-
    defaults:
      camera:
        pipeline: rtspsrc location={{.uri}} latency=1000 ! queue ! rtpjitterbuffer latency=250 ! queue ! rtph264depay ! queue ! nvv4l2decoder ! queue ! nvvideoconvert ! video/x-raw(memory:NVMM),width=1920,height=1080 ! m.sink_0 nvstreammux name=m batch-size=4 width=1920 height=1080 ! queue ! nvinferserver name=nvis config-file-path=/models/rtdetr_config.pbtxt unique-id=2 interval=15 ! queue ! nvinferserver config-file-path=/models/up_down_classifier_config.pbtxt unique-id=5 ! queue ! nvtracker tracker-width=640 tracker-height=384 gpu-id=0 ll-lib-file=/opt/nvidia/deepstream/deepstream/lib/libnvds_nvmultiobjecttracker.so ll-config-file=/models/config_tracker_NvDeepSORT.yml compute-hw=2 ! nvstreamdemux name=d d.src_0 ! queue ! tee name=t t. ! queue ! nvvideoconvert ! video/x-raw(memory:NVMM),width=1920,height=1080 ! nvv4l2h265enc copy-meta=true iframeinterval=15 bitrate=250000 ! queue ! h265parse ! queue ! splitmuxsink sink=nvdsfilesink muxer-properties=properties,streamable=true location=/app/videos/{{.camera_id}}_%05d.mp4 max-size-time=15000000000 max-files=5760 t. ! queue ! nvdsanalytics config-file=/app/config/config_nvdsanalytics.txt ! queue ! nvdsosd ! nvvideoconvert ! video/x-raw(memory:NVMM),width=[1,1920],height=[1,1080],pixel-aspect-ratio=1/1 ! nvvideoconvert ! queue ! nvjpegenc quality=45 ! appsink sync=0 name=mqttsink t. ! nvvideoconvert ! video/x-raw,format=RGB,width=[1,640],height=[1,360],pixel-aspect-ratio=1/1 ! nvvideoconvert ! motioncells threshold=0.00005 gridx=32 gridy=18 ! fakesink
    instances:
      - name: teknoir-nvr-2x3090-se-axis
        camera:
          uri: rtsp://teknoir:password@192.168.2.2/axis-media/media.amp?videocodec=h264&fps=15&resolution=1920x1080
        nvdsanalytics:
          enabled: true
          config: |
            [property]
            enable=1
            config-width=1920
            config-height=1080
            osd-mode=2
            display-font-size=25

            [line-crossing-stream-0]
            enable=1
            line-crossing-Entry-0=59;591;153;557;200;688;106;426
            line-crossing-Exit-0=247;523;153;557;106;426;200;688
            line-crossing-Entry-1=1607;566;1508;550;1568;183;1448;917
            line-crossing-Exit-1=1410;534;1508;550;1448;917;1568;183
      - name: teknoir-nvr-2x3090-se-anders-test
        camera:
          uri: rtsp://rtsp-video-file-streams:8554/vid5
        nvdsanalytics:
          enabled: true
          config: |
            [property]
            enable=1
            config-width=1920
            config-height=1080
            osd-mode=0
            display-font-size=25
```

## Adding the repository

```bash
helm repo add teknoir-nvr https://teknoir.github.io/nvr-helm/
```

## Installing the chart

```bash
helm install nvr teknoir-nvr/nvr -f values.yaml
```