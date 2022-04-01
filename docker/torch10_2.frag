# Dockerfile fragment for Pytorch installation with Cuda 10.2 (default as of 2022-04-01)

ARG TRANSFORMERS_CACHE=/workspace/bdbd2_ws/.transformerscache
ENV TRANSFORMERS_CACHE=$TRANSFORMERS_CACHE

RUN python3 -m pip install torch torchvision torchaudio

