#!/usr/bin/env bash

set -euo pipefail

job="no-error-kafka"

investigation="$HOME/Documents/github/no-error-kafka"
checkstyle="$HOME/Documents/github/checkstyle"
# CircleCI config.
cci_config="$checkstyle/.circleci/config.yml"
# Expanded CircleCI config.
exp_cci_config="$investigation/.circleci/config.yml"

echo "Validating CircleCI config."
circleci config validate "$cci_config"

echo "Expanding CircleCI config."
mkdir -p "$investigation/.circleci"
circleci config process "$cci_config" > "$exp_cci_config"

timestamp=$(date +%Y%m%d_%H-%M-%S)
archive_dir="$investigation/archives/$timestamp"
echo "Creating archive directory '$archive_dir'."
mkdir -p "$archive_dir"

echo "Copying Bash script to archive directory."
cp "$checkstyle/.ci/no-error-kafka.sh" "$archive_dir/"

echo "Starting CircleCI '$job' job in local Docker container."
gnome-terminal -- bash -c \
  "cd \"$checkstyle\"; circleci local execute -c \"$exp_cci_config\" \"$job\" 2>&1 \
    | ts '[%Y-%m-%d %H:%M:%S]' \
    | tee \"$archive_dir/no-error-kafka.log\""

container_id=""
while [ -z "$container_id" ]; do
  echo "Waiting for Docker container to start."
  container_id="$(docker container ls --quiet --filter "ancestor=cimg/openjdk:21.0.6")"
  sleep 1
done

echo "Docker container started with ID '$container_id'."

output_data="$archive_dir/docker-stats.csv"
echo "Writing CSV header to '$output_data'."
echo "timestamp,cpu_perc,mem_usage,net_io,block_io,pids" > "$output_data"

echo "Listening to stats for container $container_id every second."
while true; do
  ts=$(date +%Y-%m-%dT%H:%M:%S%z)

  stats=$(docker stats "$container_id" \
    --no-stream \
    --format "{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}},{{.PIDs}}") || true

  if [[ -z "$stats" ]]; then
    echo "Container '$container_id' no longer exists or has stopped."
    break
  fi

  echo "Recording stats at '$ts'."
  echo "$ts,$stats" >> "$output_data"

  sleep 1
done

echo "Generating visualizations."
jupyter nbconvert --to notebook --execute "$investigation/visualizations.ipynb" --inplace
