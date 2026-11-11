# Keeps track of the Hugging Face models on disk, and removes the least recently used
# ones when a new download would leave less than 5 GB free. Both file2BERT.py (Python 3.6)
# and file2BERT_hf.py (Python 3.11) use this module, so it must run on Python 3.6.
#
# The models in ~/.cache/huggingface/transformers are never removed. They are the models
# SemanticExcel had before Hugging Face could be chosen freely, and old analyses must give
# the same results.
import glob
import json
import os
import re
import shutil
import time

cacheDir = os.path.expanduser("~/.cache/huggingface")
minFreeBytes = 5 * 1024**3
# A model used in the last hour may be in use by another calculation, so it is kept
recentSeconds = 3600
usedMarker = ".semanticexcel_last_used"
logFile = os.path.join(cacheDir, "semanticexcel-removed-models.log")
# The web server cannot read /root, so the names of the models on disk are written here for it
inventoryFile = "/home/semantic/semanticmatlab/hf-models-on-server.json"

def modelFolders(name):
  """The folders that can hold a model: the Hugging Face hub cache and the hand-fetched folder."""
  return [os.path.join(cacheDir, "hub", "models--" + name.replace("/", "--")),
          os.path.join(cacheDir, "semanticexcel", name.replace("/", "--"))]

def markUsed(name):
  for folder in modelFolders(name):
    if os.path.isdir(folder):
      with open(os.path.join(folder, usedMarker), "w") as marker:
        marker.write(str(time.time()))
  writeInventory()

def modelsOnServer():
  names = set()
  for record in glob.glob(os.path.join(cacheDir, "transformers", "*.json")):
    try:
      url = json.load(open(record)).get("url", "")
    except Exception:
      continue
    found = re.match(r"https://huggingface.co/(.+?)/resolve/", url)
    if found:
      names.add(found.group(1))
  for folder in glob.glob(os.path.join(cacheDir, "hub", "models--*")):
    if glob.glob(os.path.join(folder, "snapshots", "*", "config.json")):
      names.add(os.path.basename(folder)[len("models--"):].replace("--", "/", 1))
  for folder in glob.glob(os.path.join(cacheDir, "semanticexcel", "*")):
    if os.path.exists(os.path.join(folder, ".complete")):
      names.add(os.path.basename(folder).replace("--", "/", 1))
  return sorted(names)

def writeInventory():
  partial = inventoryFile + ".part" + str(os.getpid())
  with open(partial, "w") as out:
    json.dump(modelsOnServer(), out)
  os.chmod(partial, 0o644)
  os.rename(partial, inventoryFile)

def lastUsed(folder):
  marker = os.path.join(folder, usedMarker)
  return os.path.getmtime(marker if os.path.exists(marker) else folder)

def removableModels(keep):
  folders = []
  for parent in [os.path.join(cacheDir, "hub"), os.path.join(cacheDir, "semanticexcel")]:
    if os.path.isdir(parent):
      for entry in os.listdir(parent):
        folder = os.path.join(parent, entry)
        if os.path.isdir(folder) and (entry.startswith("models--") or parent.endswith("semanticexcel")) and folder not in keep:
          folders.append(folder)
  now = time.time()
  return sorted([f for f in folders if now - lastUsed(f) > recentSeconds], key=lastUsed)

def folderBytes(folder):
  # The hub cache links each model file to a blob in the same folder, so links are not counted
  files = [os.path.join(path, f) for path, dirs, names in os.walk(folder) for f in names]
  return sum(os.path.getsize(f) for f in files if not os.path.islink(f))

def makeRoom(name, neededBytes):
  """Removes least recently used models until the download leaves 5 GB free.
  Removes nothing and returns False when even removing them all would not be enough."""
  keep = modelFolders(name)
  candidates = removableModels(keep)
  if shutil.disk_usage(cacheDir).free + sum(folderBytes(f) for f in candidates) - neededBytes < minFreeBytes:
    return False
  for folder in candidates:
    if shutil.disk_usage(cacheDir).free - neededBytes >= minFreeBytes:
      break
    shutil.rmtree(folder)
    with open(logFile, "a") as log:
      log.write(time.strftime("%Y-%m-%d %H:%M:%S") + " removed " + folder + " to make room for " + name + "\n")
  writeInventory()
  return shutil.disk_usage(cacheDir).free - neededBytes >= minFreeBytes
