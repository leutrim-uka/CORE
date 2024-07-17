import os

# Directory paths
script_dir = os.path.dirname(os.path.abspath(__file__))
models_dir = os.path.join(script_dir, "..", "models")
data_dir = os.path.join(script_dir, "..", "data")
results_dir = os.path.join(script_dir, "..", "results")

# FastText model URL
fasttext_model_url = ("https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid"
                      ".176.bin")
fasttext_model_name = fasttext_model_url.split("/")[-1]

ollama_model = "mistral"
ollama_embedder = "nomic-"

# Llama model settings
research_domains = [
    "Multidisciplinary",
    "Agricultural and Biological Sciences",
    "Arts and Humanities",
    "Biochemistry, Genetics and Molecular Biology",
    "Business, Management, and Accounting",
    "Chemical Engineering",
    "Chemistry",
    "Computer Science",
    "Decision Sciences",
    "Earth and Planetary Sciences",
    "Economics, Econometrics and Finance",
    "Energy",
    "Engineering",
    "Environmental Science",
    "Immunology and Microbiology",
    "Materials Science",
    "Mathematics",
    "Medicine",
    "Neuroscience",
    "Nursing",
    "Pharmacology, Toxicology, and Pharmaceutics",
    "Physics and Astronomy",
    "Psychology",
    "Social Sciences",
    "Veterinary",
    "Dentistry",
    "Health Professions"
]


PROMPT_TEMPLATE = """
Here are all the possible categories:
{context}

---

Classify the following text into one of the categories above: {question}. Your output should be exactly one of the categories provided to you. Do not provide any explanations or context.
"""