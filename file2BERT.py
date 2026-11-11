 #!/usr/bin/python
import sys
print('Number of arguments:', len(sys.argv),str(sys.argv[1]), 'arguments.')
print('Argument List:', str(sys.argv))
#textFile="dataSmall.csv"
#model_name ="bert-base-multilingual-uncased"
#outputFile="bert_base_multilingual_outputs.csv"
#textFile="/Users/sverkersikstrom/Dropbox/semantic/file2BERT-086513.csv"
textFile=sys.argv[1]
outputFile=sys.argv[2]
model_name =sys.argv[3]


from transformers import AutoTokenizer, AutoModel
import csv
import os
import torch

# This environment has transformers 4.18, which cannot download from Hugging Face any
# more. Models it already has load exactly as before, so their results do not change.
# That includes three models fetched by hand on 2026-10-24 from known publishers.
# Any other model runs in the newer environment in /opt/hf-venv.
fetchedByHand = os.path.join(os.path.expanduser("~/.cache/huggingface/semanticexcel"), model_name.replace("/", "--"))
try:
  tokenizer = AutoTokenizer.from_pretrained(model_name, local_files_only=True)
  model = AutoModel.from_pretrained(model_name, local_files_only=True)
except Exception:
  if os.path.exists(os.path.join(fetchedByHand, ".complete")):
    tokenizer = AutoTokenizer.from_pretrained(fetchedByHand)
    model = AutoModel.from_pretrained(fetchedByHand)
    import modelCache
    modelCache.markUsed(model_name)
  else:
    newScript = os.path.join(os.path.dirname(os.path.abspath(__file__)), "file2BERT_hf.py")
    # MATLAB puts its own libraries in LD_LIBRARY_PATH. Python 3.11 needs only its OpenSSL.
    env = dict(os.environ, LD_LIBRARY_PATH="/root/streamlit/openssl-1.1.1")
    os.execve("/opt/hf-venv/bin/python", ["/opt/hf-venv/bin/python", newScript, textFile, outputFile, model_name], env)
with open(textFile, "r") as read_file:
  file_content = csv.reader(read_file)
  header = next(file_content)
  #print(header)
  header_indices = dict(zip(header, range(len(header))))
  #print(dict(header_indices))
  with open(outputFile, "w") as wf:
    for i in file_content:
      encoded_input = tokenizer(i[header_indices["text"]], return_tensors='pt', truncation=True)
      #print(encoded_input)
      #break
      output = model(**encoded_input, output_hidden_states=True)
      #print(output)
      #print (i[header_indices["Keywords"]], torch.mean(output['last_hidden_state'][0],0).shape)
      #print(list(torch.mean(output['last_hidden_state'][0],0).detach().numpy()))
      #print("Size of the embedding: ",torch.mean(output['last_hidden_state'][0],0))
      #break
      wf.write(str(list(torch.mean(output['last_hidden_state'][0],0).detach().numpy())) + "\n")
