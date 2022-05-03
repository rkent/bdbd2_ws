# Install required libraries
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    wget \
    zlib1g-dev \
    git \
    pkg-config \
    sudo \
    ssh \
    libssl-dev \
    pbzip2 \
    pv \
    bzip2 \
    unzip \
    devscripts \
    lintian \
    fakeroot \
    dh-make \
    build-essential

# Bazel, I used bazelisk to get this location
ARG BAZEL_VERSION=5.1.1
RUN wget https://releases.bazel.build/$BAZEL_VERSION/release/bazel-$BAZEL_VERSION-linux-arm64 -O /usr/local/bin/bazel
RUN chmod +x /usr/local/bin/bazel

# Get the source
# Adapted from https://github.com/NVIDIA/Torch-TensorRT/blob/master/docker/Dockerfile
ENV TOP_DIR="/workspaces/torch-tensorrt"
RUN git clone https://github.com/nvidia/torch-tensorrt $TOP_DIR

FROM base as torch-tensorrt-builder-base

# Removing any torch-tensorrt pre-installed from the base image
#RUN rm -rf /opt/pytorch/torch_tensorrt

ARG TARGETARCH="arm64"
ARG HOSTTYPE="aarch64"

# Workaround for bazel expecting both static and shared versions, we only use shared libraries inside container
#RUN touch /usr/lib/$HOSTTYPE-linux-gnu/libnvinfer_static.a

RUN apt-get update && apt-get install -y --no-install-recommends locales ninja-build && rm -rf /var/lib/apt/lists/* && locale-gen en_US.UTF-8

FROM torch-tensorrt-builder-base as torch-tensorrt-builder

# Removing any bazel or torch-tensorrt pre-installed from the base image
#RUN rm -rf /opt/pytorch/torch_tensorrt


#  Torch-TensorRT/docker/dist-build.sh 
WORKDIR $TOP_DIR
RUN git checkout v1.0.0
# Overwrite the WORKSPACE with our modified configuration
COPY docker/jtensorrt.WORKSPACE $TOP_DIR
RUN rm $TOP_DIR/WORKSPACE && mv $TOP_DIR/jtensorrt.WORKSPACE $TOP_DIR/WORKSPACE 

RUN mkdir -p dist
WORKDIR $TOP_DIR/py
ENV MAX_JOBS=1
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda-10.2/targets/aarch64-linux/lib:"
RUN python3 setup.py bdist_wheel --use-cxx11-abi $* || exit 1

RUN pip3 install ipywidgets --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org
RUN jupyter nbextension enable --py widgetsnbextension
RUN pip3 install timm
RUN pip3 install nvidia-pyindex
RUN pip3 install polygraphy onnx onnx_graphsurgeon toml 

# test install
RUN pip3 install ${TOP_DIR}/py/dist/*.whl

WORKDIR /workspaces/bdbd2_ws
