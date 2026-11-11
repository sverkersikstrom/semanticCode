# Runs a Hugging Face model in the newer Python environment in /opt/hf-venv.
# file2BERT.py hands a model over to this script when the old environment
# does not already have it. The output format is the same as file2BERT.py.
import sys

textFile = sys.argv[1]
outputFile = sys.argv[2]
model_name = sys.argv[3]

import csv
import inspect
import torch
from huggingface_hub import HfApi, try_to_load_from_cache
from transformers import AutoModel, AutoTokenizer
import modelCache

def checkModel(name):
  if isinstance(try_to_load_from_cache(name, "config.json"), str):
    return
  try:
    info = HfApi().model_info(name, files_metadata=True)
  except Exception as error:
    sys.exit("The model " + name + " was not found on huggingface.co (" + type(error).__name__ + ")")
  # Weights in .bin files are Python pickles, which can run code when loaded.
  # Only safetensors files are accepted, because they hold numbers alone.
  weights = [f for f in info.siblings if f.rfilename.endswith(".safetensors")]
  if not weights:
    sys.exit("The model " + name + " has no safetensors weights, and .bin weights are not accepted for safety reasons")
  # A download must leave 5 GB free, so the server keeps running
  if not modelCache.makeRoom(name, sum(f.size or 0 for f in weights)):
    sys.exit("Not enough free disk space to download the model " + name)

checkModel(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModel.from_pretrained(model_name, use_safetensors=True)
model.eval()
modelCache.markUsed(model_name)
# Some tokenizers add fields the model does not take, such as token_type_ids for ModernBERT
accepted = set(inspect.signature(model.forward).parameters)
with open(textFile, "r") as read_file:
  file_content = csv.reader(read_file)
  header = next(file_content)
  header_indices = dict(zip(header, range(len(header))))
  with open(outputFile, "w") as wf:
    for i in file_content:
      encoded = tokenizer(i[header_indices["text"]], return_tensors='pt', truncation=True)
      encoded_input = {k: v for k, v in encoded.items() if k in accepted}
      with torch.no_grad():
        output = model(**encoded_input)
      wf.write(str(torch.mean(output['last_hidden_state'][0], 0).tolist()) + "\n")
