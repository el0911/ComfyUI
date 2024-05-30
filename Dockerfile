FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Los_Angeles

ARG USE_PERSISTENT_DATA

RUN apt-get update && apt-get install -y \
    git \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev git git-lfs  \
    ffmpeg libsm6 libxext6 cmake libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt


# User
USER root
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Pyenv
RUN curl https://pyenv.run | bash
ENV PATH=$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH

ARG PYTHON_VERSION=3.10.12
# Python
RUN pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    pyenv rehash && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
    datasets \
    huggingface-hub "protobuf<4" "click<8.1"

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Set the working directory to /data if USE_PERSISTENT_DATA is set, otherwise set to $HOME/app
WORKDIR $HOME/app

COPY . .

RUN  pip install opencv-python
RUN pip install insightface


RUN echo "Done"

 
# Controlnet Preprocessor nodes by Fannovel16
#RUN cd custom_nodes && git clone https://github.com/Fannovel16/comfy_controlnet_preprocessors && cd comfy_controlnet_preprocessors && python install.py --no_download_ckpts # this guy just deleted his repo
RUN cd custom_nodes && git clone https://github.com/el0911/comfyui_controlnet_aux_el && cd comfyui_controlnet_aux_el && pip install -r requirements.txt
RUN cd custom_nodes && git clone https://github.com/Extraltodeus/ComfyUI-AutomaticCFG  && cd ComfyUI-AutomaticCFG && pip install -r requirements.txt
RUN cd custom_nodes && git clone https://github.com/Stability-AI/stability-ComfyUI-nodes && cd stability-ComfyUI-nodes && pip install -r requirements.txt 
RUN cd custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack  
RUN cd custom_nodes && git clone https://github.com/EllangoK/ComfyUI-post-processing-nodes
 # ComfyUI Manager !!Important
RUN cd custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

RUN echo "Done"

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--output-directory", "output"]

