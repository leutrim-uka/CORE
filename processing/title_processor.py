import os
import lzma
import csv
import json
from language_domain_detection import LanguageDetector, LlamaClassifier
from config import ollama_model


class TitleProcessor:
    def __init__(self, data_dir: str, results_dir: str):
        self.data_dir = data_dir
        self.results_dir = results_dir
        self.language_detector = LanguageDetector()

    def process_file(self, file_name: str):
        results = []
        file_path = os.path.join(self.data_dir, file_name)

        llama_classifier = LlamaClassifier(model_name=ollama_model)

        with lzma.open(file_path, mode="rt", encoding="utf-8") as f:
            for line in f:
                try:
                    document = json.loads(line.strip())
                    core_id = document.get("coreId")
                    title = document.get("title")
                    if title is None:
                        title = document.get("fullText")
                        # If also full text is empty, continue to next article
                        if title is None:
                            continue
                        else:
                            # If there's full text, take first 50 chars
                            title = title[:50]
                    language = self.language_detector.predict_language(title)
                    category = llama_classifier.classify(title)
                    # category = "test"
                    results.append((core_id, language, category))

                except json.JSONDecodeError:
                    print(f"Skipping malformed JSON line: {line.strip()}")

        output_file_path = os.path.join(self.results_dir,
                                        f"{os.path.basename(file_path)}_lang.csv")
        with open(output_file_path, 'w', newline='', encoding='utf-8') as csvfile:
            csv_writer = csv.writer(csvfile)
            csv_writer.writerow(['core_id', 'language', 'category'])  # Write header row
            csv_writer.writerows(results)  # Write data rows


