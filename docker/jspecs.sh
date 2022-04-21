# Specs of Dockerfiles used on jetson devices

declare -A specs

# Define the contents of Dockerfiles
specs=(\
  [jtorch]="jtorch base"\
  [jbase]="jbase base" \
  [jtransformers]="jtorch base transformers" \
  [jtensorrt]="jtorch base transformers jtensorrt"
)
