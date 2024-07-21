import os
import time
import multiprocessing
from tqdm import tqdm
from config import data_dir, results_dir
from title_processor import TitleProcessor


def main():
    processor = TitleProcessor(data_dir, results_dir)

    start_time = time.time()
    filenames = [filename for filename in os.listdir(data_dir) if filename.endswith(".json.xz")]

    for filename in filenames:
        processor.process_file(filename)

    elapsed_time = time.time() - start_time
    print(f"Language processing for {len(filenames)} files completed in {elapsed_time:.2f} seconds")

if __name__ == "__main__":
    main()
