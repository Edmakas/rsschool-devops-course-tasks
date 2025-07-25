# Stress CPU for 30 seconds
stress --cpu 4 --timeout 30

# Stress memory for 60 seconds
stress --vm 2 --vm-bytes 1G --timeout 60

# Stress both CPU and memory
stress --cpu 2 --vm 1 --vm-bytes 512M --timeout 45
