import lzma
import csv
import json
import fasttext
import wget
import os
import time
import multiprocessing

# Link to the fasttext model for language detection
FASTTEXT_MODEL_URL = ("https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid"
                      ".176.bin")

# Extract the name of model to check if model is already downloaded
fasttext_model_name = FASTTEXT_MODEL_URL.split("/")[-1]

# Determine the absolute path to the models directory
script_dir = os.path.dirname(os.path.abspath(__file__))
models_dir = os.path.join(script_dir, "..\\models")
data_dir = os.path.join(script_dir, "..\\data")
results_dir = os.path.join(script_dir, "..\\results")

# Download the model if it's not yet been downloaded
if fasttext_model_name not in os.listdir(models_dir):
    wget.download(FASTTEXT_MODEL_URL, out=models_dir)

# Load the model downloaded previously
try:
    model = fasttext.load_model(os.path.join(models_dir, fasttext_model_name))
except FileNotFoundError as e:
    print(f"Model file not found: {e}")


def predict_language(text: str):
    text = text.replace("\n", "")
    prediction = model.predict(text, k=1)
    return prediction[0][0].split("__label__")[-1]


def process_file(file_name, data_dir, results_dir):
    results = []
    file_path = os.path.join(data_dir, file_name)

    with lzma.open(file_path, mode='rt', encoding='utf-8') as f:
        for line in f:
            try:
                document = json.loads(line.strip())
                core_id = document.get("id")
                title = document.get("title")
                if title is None:
                    continue
                language = predict_language(title)
                results.append((core_id, language))
            except json.JSONDecodeError:
                print(f"Skipping malformed JSON line: {line.strip()}")

    output_file_path = os.path.join(results_dir,
                                    f"{os.path.basename(file_path)}_lang.csv")
    with open(output_file_path, 'w', newline='', encoding='utf-8') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['core_id', 'language'])  # Write header row
        csv_writer.writerows(results)  # Write data rows


if __name__ == "__main__":
    start_time = time.time()
    filenames = [filename for filename in os.listdir(data_dir) if
                     filename.endswith(".json.xz")]
    p = multiprocessing.Pool()
    for filename in filenames:
        p.apply_async(process_file, [filename, data_dir, results_dir])
    p.close()
    p.join()

    elapsed_time = time.time() - start_time
    print(f"Language processing for {len(filenames)} completed in {elapsed_time} "
          f"seconds")
