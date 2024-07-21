# Data processing
The data for this analysis is provided by CORE. The dataset contains millions of papers, organized into JSON files. In our analysis, we consider only papers that provide the entire full text, not just abstracts.

## Cleaning compressed JSON files
Since the dataset is relatively large (few terabytes when decompressed), we attempt to reduce the size by removing unnecessary entires, i.e., papers with no full text included.

For this task, we use `parallel_dataset_filtering.sh`, where multiple files can be processed concurrently using the `parallel` library.

### Dependencies
1. `jq`: for processing the JSON content
2. `xz`: for working with XZ (compressed) files
3. `parallel`: for parallel processing of JSON files

To install the dependencies, you need sudo rights:
```{bash}
sudo apt-get install jq xz parallel
```

To run the script, ensure it has executable permissions:
```{bash}
chmod +x parallel_dataset_filtering.sh
```

The script generates three different outputs:
1. `filtered_dataset` (directory): contains the cleaned json.xz files
2. `temp_output_parallel_filtering` (directory): a temporary storage location for JSON files during the processing phase. Will be automatically deleted.
3. `parallel_processing_logs.log` (file): a file to log the events during execution

If a file from the dataset happens to not have any full-text articles, the corresponding json.xz file will not be stored in the output directory.

_Note: There is a second file with an alternative approach for this very task: `alternative_dataset_filtering.sh`. This file doesn't use the `parallel` library, as we didn't have sudo rights to install it in the cluster. The output remains the same._

# Running with Docker
First, build the image using the Dockerfile through the following command:
```{bash}
docker build -t core-image .
```

Then run the container based on the built image with this command:
```{bash}
docker run --gpus all --name core-container -p 11434:11434 -v ~/data:/app/data -v ~/results:/app/results core-image
```
