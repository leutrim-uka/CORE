import os
import time
import multiprocessing
from tqdm import tqdm
from config import data_dir, results_dir
from title_processor import TitleProcessor

def init_worker(data_dir, results_dir):
    global processor
    processor = TitleProcessor(data_dir, results_dir)

def process_file(filename):
    global processor
    processor.process_file(filename)

def main():
    start_time = time.time()
    filenames = [filename for filename in os.listdir(data_dir) if filename.endswith(".json.xz")]

    with tqdm(total=len(filenames)) as pbar:
        with multiprocessing.Pool(initializer=init_worker, initargs=(data_dir, results_dir)) as pool:
            for filename in filenames:
                pool.apply_async(process_file, args=(filename,), callback=lambda _: pbar.update(1))
            pool.close()
            pool.join()

    elapsed_time = time.time() - start_time
    print(f"Language processing for {len(filenames)} files completed in {elapsed_time:.2f} seconds")

if __name__ == "__main__":
    main()