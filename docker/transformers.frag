# Dockerfile fragment to install huggingface transformers

ARG TRANSFORMERS_CACHE=/workspaces/bdbd2_ws/.transformerscache
ENV TRANSFORMERS_CACHE=$TRANSFORMERS_CACHE

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade packaging
RUN python3 -m pip install setuptools-rust
RUN python3 -m pip install transformers

