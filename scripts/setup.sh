#!/bin/bash

base_dir=$(cd "$(dirname "$0")" && pwd)
target=$1

if [[ ${target} = "gha" ]] ; then
  num_of_docs=120000
  data_files="
0000.parquet
0001.parquet
"
else
  num_of_docs=5555583
  data_files="
0000.parquet
0001.parquet
0002.parquet
0003.parquet
0004.parquet
0005.parquet
0006.parquet
0007.parquet
"
fi

# wikipedia contents
data_type=passages-c400-jawiki-20230403
model_type=text-embedding-3-small-dim512
setting_type=100k-1536-m32-efc200-ef100-ip

data_dir="${base_dir}/../dataset/${data_type}"
output_dir="${base_dir}/../output"

mkdir -p "${data_dir}" "${output_dir}"

for data_file in ${data_files} ; do
  if [[ ! -f "${data_dir}/${data_file}" ]] ; then
    echo -n "Downloading ${data_file}... "
    curl -sL -o "${data_dir}/${data_file}" \
      "https://huggingface.co/datasets/singletongue/wikipedia-utils/resolve/refs%2Fconvert%2Fparquet/${data_type}/train/${data_file}?download=true" || exit 1
    echo "[OK]"
  fi
done

mkdir -p "${data_dir}/${model_type}"

count=0
while [[ ${count} -lt ${num_of_docs} ]] ; do
  data_file="${data_dir}/${model_type}/${count}.npz"
  if [[ ! -f "${data_file}" ]] ; then
    echo -n "Downloading ${count}.npz... "
    curl -sL -o "${data_file}" \
      "https://huggingface.co/datasets/hotchpotch/wikipedia-passages-jawiki-embeddings/resolve/main/embs/${data_type}/${model_type}/${count}.npz" || exit 1
    echo "[OK]"
  fi
  count=$((count + 100000))
done


truth_type=$(echo ${setting_type} | sed -e "s/-m.*//")
truth_dir="${base_dir}/../dataset/ground_truth/${truth_type}"

mkdir -p "${truth_dir}"

truth_files="
knn_10.jsonl.gz
knn_100.jsonl.gz
knn_400.jsonl.gz
knn_10_filtered.jsonl.gz
knn_100_filtered.jsonl.gz
knn_400_filtered.jsonl.gz
"

for truth_file in ${truth_files} ; do
  if [[ ! -f "${truth_dir}/${truth_file}" ]] ; then
    echo -n "Downloading ${truth_file}... "
    curl -sL -o "${truth_dir}/${truth_file}" \
      "https://codelibs.co/download/ann/benchmark/${truth_type}/${truth_file}" || exit 1
    echo "[OK]"
  fi
done

