sudo docker run -p 8188:8188  --gpus all -v $(pwd)/models:/home/user/app/models -v $(pwd)/output:/home/user/app/output --network host comfy
