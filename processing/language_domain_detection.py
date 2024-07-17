import os
import fasttext
import wget
from langchain.prompts import ChatPromptTemplate
from langchain_community.llms.ollama import Ollama

from config import models_dir, fasttext_model_url, fasttext_model_name, research_domains, PROMPT_TEMPLATE


class LanguageDetector:
    def __init__(self):
        self.model_path = os.path.join(models_dir, fasttext_model_name)
        self._download_model()
        self.model = fasttext.load_model(self.model_path)

    def _download_model(self) -> None:
        if not os.path.exists(self.model_path):
            wget.download(fasttext_model_url, out=models_dir)

    def predict_language(self, text: str) -> str:
        text = text.replace("\n", "")
        prediction = self.model.predict(text, k=1)
        return prediction[0][0].split("__label__")[-1]


class LlamaClassifier:
    def __init__(self, model_name: str):
        self.model = Ollama(model=model_name)
        self.test = 1234

    def classify(self, text: str) -> str:
        prompt_template = ChatPromptTemplate.from_template(PROMPT_TEMPLATE)
        prompt = prompt_template.format(context=research_domains, question=text)
        response_text = self.model.invoke(prompt)
        return response_text

