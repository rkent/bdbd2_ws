# Specs of Dockerfiles

declare -A specs

# Define the contents of Dockerfiles
specs=(\
  [ubuntu20]="ubuntu20"\
  [ros2base]="ubuntu20 ros2base"\
  [demo_nodes_cpp]="ubuntu20 ros2base demo_nodes_cpp"\
  [ros2dev]="ubuntu20 ros2base ros2dev"\
  [ros2desktop]="ubuntu20 ros2base ros2dev ros2desktop"\
  [torch10_2]="ubuntu20 ros2base ros2dev torch10_2"\
  [transformers10_2]="ubuntu20 ros2base ros2dev torch10_2 transformers"
)
