# Specs of Dockerfiles

declare -A specs

# Define the contents of Dockerfiles
specs=(\
  [ubuntu20]="ubuntu20 base"\
  [ubu20cuda113]="ubu20cuda113 base"\
  [ros2base]="ubuntu20 base ros2base"\
  [ros2cuda113]="ubu20cuda113 base ros2base ros2dev ros2desktop"
  [demo_nodes_cpp]="ubuntu20 base ros2base demo_nodes_cpp"\
  [ros2dev]="ubuntu20 base ros2base ros2dev"\
  [ros2desktop]="ubuntu20 base ros2base ros2dev ros2desktop"\
  [torch]="ubuntu20 base ros2base ros2dev torch10_2"\
  [torch11_3]="ubu20cuda113 base ros2base ros2dev ros2desktop torch11_3"\
  [transformers]="ubuntu20 base ros2base ros2dev torch10_2 transformers"\
  [transformers11_3]="ubu20cuda113 base ros2base ros2dev ros2desktop torch11_3 transformers"
)
