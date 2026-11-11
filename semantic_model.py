"""Check and apply a Semantic Measure Model file (format 0.2).

A model file describes a prediction model as data, not code: how a text becomes a
vector with a Hugging Face model, and the weights of a linear or logistic model on
that vector. This script checks a file and computes predictions with SemanticExcel's
own code, so a file can never run code of its own.

  python semantic_model.py validate model.json   report.json
  python semantic_model.py predict  model.json   texts.json  predictions.json
  python semantic_model.py export   space        model_id    name  description  model.json

validate checks the file and then computes the reference texts. The file passes only
if every prediction matches the author's own prediction within the tolerance. That
check shows that this server turns texts into the same vectors as the author did.
A file without "revision" is checked with the current version of the language model,
and the report gives that version, so the caller can pin it in the file.

Runs in /opt/hf-venv (Python 3.11, transformers 4.57). Model loading follows
file2BERT_hf.py: safetensors weights only, and a download must leave 5 GB free.
"""
import json
import math
import os
import re
import sys

FORMAT = "semantic-measure-model/0.2"
MAX_FILE_BYTES = 2 * 1024 * 1024
MAX_TEXT_CHARS = 5000
MIN_REFERENCES, MAX_REFERENCES = 5, 100
MODEL_NAME = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)?$")
REVISION = re.compile(r"^[0-9a-f]{40}$")

# SemanticExcel's own pipeline. A file that leaves out a setting gets this value.
DEFAULT_EMBEDDING = {"layer": -1, "special_tokens": "include", "max_tokens": None, "normalize": "l2", "prefix": ""}
# The classic SemanticExcel spaces a file can name instead of a Hugging Face model. Their words
# can be downloaded from semanticexcel.com/files/spaces/, and their dimensions are given here.
SPACES = {"spaceEnglish": 512, "spaceEnglish2": 512}
# SemanticExcel puts spaces around these characters before it splits a text into words
SEPARATORS = '\\".,!?;&?()[]/<>:$%`-='
FIELDS = {"format", "name", "language_model", "space", "weights", "onnx", "reference", "revision", "intercept", "logistic",
          "threshold", "tolerance", "description", "min", "max", "training"} | set(DEFAULT_EMBEDDING)


class FileError(Exception):
    """The model file is wrong in a way its author can fix."""


def number(value, where):
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise FileError(where + " must be a finite number")
    return float(value)


def read_model(path):
    """Read and check everything that can be checked without the language model."""
    if os.path.getsize(path) > MAX_FILE_BYTES:
        raise FileError("The file is larger than 2 MB")
    try:
        with open(path, encoding="utf-8") as f:
            return parse_model(f.read())
    except UnicodeDecodeError as e:
        raise FileError("The file is not valid UTF-8: " + str(e))


def hugging_face_settings(m):
    """The Hugging Face settings of a file, checked."""
    emb = dict(DEFAULT_EMBEDDING)
    emb.update({k: m[k] for k in DEFAULT_EMBEDDING if k in m})
    emb["model"] = m["language_model"]
    emb["revision"] = m.get("revision")
    if emb["revision"] is not None and not REVISION.match(str(emb["revision"])):
        raise FileError('"revision" must be the 40-character commit hash of the model version on huggingface.co')
    if not isinstance(emb["layer"], int) or isinstance(emb["layer"], bool):
        raise FileError('"layer" must be a whole number, for example -1 for the last layer')
    if emb["special_tokens"] not in ("include", "exclude"):
        raise FileError('"special_tokens" must be "include" or "exclude"')
    if emb["max_tokens"] is not None and (not isinstance(emb["max_tokens"], int) or emb["max_tokens"] < 2):
        raise FileError('"max_tokens" must be empty or a whole number of at least 2')
    if emb["normalize"] not in ("l2", "none"):
        raise FileError('"normalize" must be "l2" or "none"')
    if not isinstance(emb["prefix"], str) or len(emb["prefix"]) > 100:
        raise FileError('"prefix" must be a short text, such as "query: "')
    return emb


def parse_model(text):
    try:
        m = json.loads(text)
    except ValueError as e:
        raise FileError("The file is not valid JSON: " + str(e))
    if not isinstance(m, dict) or m.get("format") != FORMAT:
        raise FileError('"format" must be "%s"' % FORMAT)
    unknown = sorted(set(m) - FIELDS)
    if unknown:
        raise FileError("The file has fields that the format does not have: %s. Check the spelling." % ", ".join(unknown))
    if not isinstance(m.get("name"), str) or not m["name"].strip():
        raise FileError('"name" must say what the model predicts, for example "PHQ-9 total score"')

    if "space" in m:
        # A classic SemanticExcel space: the text vector is the normalized sum of its word vectors
        if m["space"] not in SPACES:
            raise FileError('"space" must be one of: ' + ", ".join(sorted(SPACES)))
        other = sorted(k for k in ["language_model", "revision"] + list(DEFAULT_EMBEDDING) if k in m)
        if other:
            raise FileError('A file with "space" has no Hugging Face settings, but this file has: ' + ", ".join(other))
        emb = {"space": m["space"]}
    elif not MODEL_NAME.match(str(m.get("language_model", ""))):
        raise FileError('"language_model" must be a Hugging Face model name such as "intfloat/multilingual-e5-small", or the file must name a "space"')
    else:
        emb = hugging_face_settings(m)

    onnx = None
    if "onnx" in m:
        # A nonlinear model as an ONNX graph. It replaces weights, intercept and logistic.
        if any(k in m for k in ("weights", "intercept", "logistic")):
            raise FileError('A file with "onnx" has no "weights", "intercept" or "logistic"; the ONNX model computes the prediction')
        try:
            import base64
            onnx = base64.b64decode(m["onnx"], validate=True)
        except Exception:
            raise FileError('"onnx" must be the ONNX model as base64 text')
        weights = []
    else:
        weights = m.get("weights")
        if not isinstance(weights, list) or not weights:
            raise FileError('"weights" must be a list of numbers, one per dimension of the language model, or the file must have "onnx"')
        weights = [number(w, "weights[%d]" % i) for i, w in enumerate(weights)]
    intercept = number(m.get("intercept", 0), "intercept")
    logistic = m.get("logistic", False)
    if not isinstance(logistic, bool):
        raise FileError('"logistic" must be true or false')
    threshold = None
    if m.get("threshold") is not None:
        if not logistic:
            raise FileError('"threshold" is only for a logistic model, with "logistic": true')
        threshold = number(m["threshold"], "threshold")
        if not 0 < threshold < 1:
            raise FileError('"threshold" must be a probability between 0 and 1')

    texts = m.get("reference")
    if not isinstance(texts, list):
        raise FileError('"reference" must list texts with the predictions the author got')
    if not MIN_REFERENCES <= len(texts) <= MAX_REFERENCES:
        raise FileError('"reference" must have between %d and %d texts' % (MIN_REFERENCES, MAX_REFERENCES))
    pairs = []
    for i, t in enumerate(texts):
        if not isinstance(t, dict) or not isinstance(t.get("text"), str) or not t["text"].strip():
            raise FileError('"reference[%d].text" must be a text' % i)
        if len(t["text"]) > MAX_TEXT_CHARS:
            raise FileError('"reference[%d].text" is longer than %d characters' % (i, MAX_TEXT_CHARS))
        pairs.append((t["text"], number(t.get("prediction"), "reference[%d].prediction" % i)))
    expected = [p for _, p in pairs]
    spread = max(expected) - min(expected)
    if spread <= 0:
        raise FileError('The reference predictions must differ from each other, or the check proves nothing')
    tolerance = m.get("tolerance")
    tolerance = number(tolerance, "tolerance") if tolerance is not None else 0.001 * spread

    return {"raw": m, "embedding": emb, "logistic": logistic, "weights": weights, "intercept": intercept,
            "threshold": threshold, "references": pairs, "tolerance": tolerance, "onnx": onnx}


ONNX_PYTHON = "/opt/onnx-venv/bin/python"
ONNX_SCORER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "onnx_score.py")


def onnx_predict(m, vectors):
    """The ONNX model's predictions for the vectors, computed by onnx_score.py in its own environment."""
    import base64
    import subprocess
    if not os.path.exists(ONNX_PYTHON):
        raise FileError("ONNX models are not available on this server yet")
    request = json.dumps({"onnx": base64.b64encode(m["onnx"]).decode(), "vectors": vectors})
    try:
        out = subprocess.run([ONNX_PYTHON, ONNX_SCORER], input=request.encode("utf-8"), stdout=subprocess.PIPE,
                             stderr=subprocess.DEVNULL, timeout=300, env={"PATH": "/usr/bin:/bin"}).stdout
        result = json.loads(out.decode("utf-8"))
    except Exception as error:
        raise FileError("The ONNX model could not be run (%s)" % type(error).__name__)
    if not result.get("ok"):
        raise FileError(result.get("message", "The ONNX model could not be run"))
    return result["predictions"]


def load_language_model(name, revision):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import inspect
    from huggingface_hub import HfApi, try_to_load_from_cache
    from transformers import AutoModel, AutoTokenizer
    import modelCache
    if not isinstance(try_to_load_from_cache(name, "config.json", revision=revision), str):
        try:
            info = HfApi().model_info(name, revision=revision, files_metadata=True)
        except Exception as error:
            raise FileError("The model %s was not found on huggingface.co (%s)" % (name, type(error).__name__))
        weights = [f for f in info.siblings if f.rfilename.endswith(".safetensors")]
        if not weights:
            raise FileError("The model %s has no safetensors weights, and .bin weights are not accepted for safety reasons" % name)
        if not modelCache.makeRoom(name, sum(f.size or 0 for f in weights)):
            raise FileError("Not enough free disk space on the server to download the model " + name)
    tokenizer = AutoTokenizer.from_pretrained(name, revision=revision)
    model = AutoModel.from_pretrained(name, revision=revision, use_safetensors=True)
    model.eval()
    modelCache.markUsed(name)
    accepted = set(inspect.signature(model.forward).parameters)
    commit = getattr(model.config, "_commit_hash", None)
    return tokenizer, model, accepted, commit


def space_tokens(text):
    """The words of a text as SemanticExcel finds them in a classic space (text2token in text2index.m)."""
    t = text.lower().replace("\u00a0", " ").replace("\u00ff", " ")
    for c in SEPARATORS:
        t = t.replace(c, " " + c + " ")
    t = re.sub(r"(\d)+ +\.+ (\d)", r"\1.\2", t)
    return t.split()


def space_word_vectors(space, words):
    """The vectors of the words that the space has, read from its table in the space2 database."""
    import subprocess
    env = dict(os.environ, MYSQL_PWD=open("/etc/semanticexcel/db_password").read().strip())
    found = {}
    words = sorted(set(w for w in words if not w.startswith("_")))
    for i in range(0, len(words), 500):
        part = ",".join("'" + w.replace("\\", "\\\\").replace("'", "\\'") + "'" for w in words[i:i + 500])
        out = subprocess.run(["mysql", "-u", "root", "--default-character-set=utf8", "space2", "-N", "--raw", "-e",
                              "select id, xdata from `%s` where id in (%s)" % (space, part)],
                             stdout=subprocess.PIPE, env=env, check=True).stdout.decode("utf-8", "replace")
        for line in out.splitlines():
            if "\t" in line:
                word, x = line.split("\t", 1)
                x = [float(v) for v in x.split()]
                # A word with a shorter vector gets NaN in the missing dimensions in SemanticExcel, and is then left out
                if len(x) == SPACES[space]:
                    found.setdefault(word.lower(), x)
    return found


def space_vectors(space, texts):
    """Text vectors in a classic space: the sum of the vectors of the words found, normalized to
    length 1, or None for a text with no word in the space (average_vector.m with SemanticExcel's settings)."""
    tokens = [space_tokens(t) for t in texts]
    found = space_word_vectors(space, [w for ts in tokens for w in ts])
    vectors = []
    for ts in tokens:
        vs = [found[w] for w in ts if w in found]
        if not vs:
            vectors.append(None)
            continue
        total = [sum(c) for c in zip(*vs)]
        length = math.sqrt(sum(x * x for x in total)) or 1.0
        vectors.append([x / length for x in total])
    return vectors


def embed(texts, emb, loaded):
    """Vectors exactly as file2BERT_hf.py makes them, with the file's settings applied."""
    import torch
    tokenizer, model, accepted, _ = loaded
    vectors = []
    for text in texts:
        args = {"return_tensors": "pt", "truncation": True}
        if emb["max_tokens"]:
            args["max_length"] = emb["max_tokens"]
        encoded = tokenizer(emb["prefix"] + text, **args)
        inputs = {k: v for k, v in encoded.items() if k in accepted}
        with torch.no_grad():
            output = model(**inputs, output_hidden_states=True)
        states = output.hidden_states[emb["layer"]][0] if emb["layer"] != -1 else output.last_hidden_state[0]
        if emb["special_tokens"] == "exclude":
            mask = tokenizer.get_special_tokens_mask(encoded["input_ids"][0].tolist(), already_has_special_tokens=True)
            keep = [i for i, special in enumerate(mask) if not special]
            if keep:
                states = states[keep]
        v = torch.mean(states, 0).tolist()
        if emb["normalize"] == "l2":
            length = math.sqrt(sum(x * x for x in v)) or 1.0
            v = [x / length for x in v]
        vectors.append(v)
    return vectors


def apply_all(m, vectors):
    if m["onnx"] is not None:
        return onnx_predict(m, vectors)
    return [apply(m, v) for v in vectors]


def apply(m, vector):
    score = m["intercept"] + sum(w * xi for w, xi in zip(m["weights"], vector))
    if m["logistic"]:
        return 1.0 / (1.0 + math.exp(-score))
    return score


def validate(path):
    m = read_model(path)
    if "space" in m["embedding"]:
        return validate_space(m)
    emb = m["embedding"]
    loaded = load_language_model(emb["model"], emb.get("revision"))
    dim = loaded[1].config.hidden_size
    if m["onnx"] is None and len(m["weights"]) != dim:
        raise FileError("The model %s gives vectors with %d dimensions, but the file has %d weights"
                        % (emb["model"], dim, len(m["weights"])))
    layers = loaded[1].config.num_hidden_layers + 1
    if not -layers <= emb["layer"] < layers:
        raise FileError('"layer" must be between %d and %d for this model' % (-layers, layers - 1))
    texts = [t for t, _ in m["references"]]
    got = apply_all(m, embed(texts, emb, loaded))
    return report(m, emb["model"], loaded[3], dim, texts, got)


def validate_space(m):
    space = m["embedding"]["space"]
    dim = SPACES[space]
    if m["onnx"] is None and len(m["weights"]) != dim:
        raise FileError("The space %s has %d dimensions, but the file has %d weights" % (space, dim, len(m["weights"])))
    texts = [t for t, _ in m["references"]]
    vectors = space_vectors(space, texts)
    missing = [t for t, v in zip(texts, vectors) if v is None]
    if missing:
        raise FileError('No word of the reference text "%s" is in the space %s' % (missing[0][:60], space))
    return report(m, space, None, dim, texts, apply_all(m, vectors))


def report(m, model, revision, dim, texts, got):
    diffs = [abs(g - e) for g, (_, e) in zip(got, m["references"])]
    worst = max(diffs)
    return {
        "ok": worst <= m["tolerance"],
        "model": model,
        "revision_used": revision,
        "dimensions": dim,
        "references": len(texts),
        "tolerance": m["tolerance"],
        "largest_difference": worst,
        "rows": [{"text": t[:80], "expected": e, "computed": g}
                 for (t, e), g in zip(m["references"], got)],
        "message": ("All %d reference predictions match within %.3g." % (len(texts), m["tolerance"]) if worst <= m["tolerance"] else
                    "The predictions do not match the author's. The largest difference is %.4g, and the tolerance is %.3g. "
                    "Check %s." % (worst, m["tolerance"], "the space and the weights" if revision is None and model in SPACES else
                                    "language_model, revision, layer, special_tokens, normalize and prefix")),
    }


def predict(path, texts):
    m = read_model(path)
    return predict_loaded(m, load_embedding(m["embedding"]), texts)


def load_embedding(emb):
    """What predict_loaded needs to turn texts into vectors: a Hugging Face model, or the name of a classic space."""
    if "space" in emb:
        return {"space": emb["space"]}
    return load_language_model(emb["model"], emb.get("revision"))


def predict_loaded(m, loaded, texts):
    if isinstance(loaded, dict):
        # A text with no word in the space gets no prediction, as in SemanticExcel
        vectors = space_vectors(loaded["space"], texts)
        ok = [v for v in vectors if v is not None]
        got = iter(apply_all(m, ok) if ok else [])
        return [next(got) if v is not None else None for v in vectors]
    if m["onnx"] is None and len(m["weights"]) != loaded[1].config.hidden_size:
        raise FileError("The number of weights does not match the model")
    return apply_all(m, embed(texts, m["embedding"], loaded))


# Texts whose predictions are put in an exported file, so that anyone who applies it can check
# that they compute the same vectors. They are varied, so that their predictions differ.
EXPORT_REFERENCES = [
    "I feel calm and happy with my life",
    "everything is chaos and I am sad",
    "I worry about my family and my health all the time",
    "my work gives me energy and meaning",
    "lonely tired and empty",
    "we laughed together with our friends at the party",
    "I am angry because nobody listens to me",
    "peace balance harmony",
    "school, exams and homework",
    "I slept badly and I have a headache today",
]

# The settings a SemanticExcel model must have for its text vectors to be the plain normalized sum
# of the word vectors, which is what the format describes
EXPORT_DEFAULTS = {"normalizeSpace": "1", "xmeanCorrection": "0", "stopwords": "[1  1  0]", "weightWordClass": "0",
                   "weightPrimacy": "0", "weightFrequency": "0", "weightLogNwords": "0", "weightFirstNWords": "0",
                   "weightRandomNWords": "0", "weightWordPosition": "0", "weightTargetWord": "''", "weightByDate": "''"}


def property_name(name):
    """The identifier SemanticExcel stores a model under (fixpropertyname.m): letters, digits and
    underscores only, "num" before a leading digit, at most 63 characters, and "_" first."""
    a = re.sub(r"[^A-Za-z0-9_]", "", name)
    if a[:1].isdigit():
        a = "num" + a
    a = a[:63]
    if a.startswith("_"):
        a = a[1:]
    return "_" + a


def export_semanticexcel(space, model_id, name, description):
    """A model file for a model trained in SemanticExcel and stored in a classic space, or FileError
    when the model uses something the format cannot describe."""
    import subprocess
    if space not in SPACES:
        raise FileError("Only models in these spaces can be exported yet: " + ", ".join(sorted(SPACES)))
    env = dict(os.environ, MYSQL_PWD=open("/etc/semanticexcel/db_password").read().strip())
    out = subprocess.run(["mysql", "-u", "root", "--default-character-set=utf8", "space2", "-N", "--raw", "-e",
                          "select replace(replace(replace(info, char(10), ' '), char(13), ' '), char(9), ' ') from `%s` where id = '%s'"
                          % (space, property_name(model_id))],
                         stdout=subprocess.PIPE, env=env, check=True).stdout.decode("utf-8", "replace").strip()
    if not out:
        raise FileError("The model %s was not found in %s" % (model_id, space))
    info = out.splitlines()[0]

    def value(key):
        m = re.search(r"d\." + re.escape(key) + r"=([^;]*);", info)
        return m.group(1).strip() if m else None

    found = re.search(r"d\.model\.x=\[([^\]]*)\]", info)
    weights = found.group(1) if found else None
    if value("model.model") not in (None, "''", "'regression'") or weights is None or "d.DLATK." in info:
        raise FileError("Only linear regression models can be exported yet")
    if value("model.train.par.trainMultipelNumericalSize") not in (None, "0") or value("model.train.par.trainOnCrossValidationOfMultipleTextsRecall"):
        raise FileError("The model uses numbers or several texts besides the text, which the format cannot describe yet")
    if value("model.train.par.BERT") not in (None, "'LSA'", "''"):
        raise FileError("The model was trained with a Hugging Face model, not with the classic space")
    for key, default in EXPORT_DEFAULTS.items():
        v = value("model.train.par." + key)
        if v is not None and v != default:
            raise FileError("The model weights the words of a text (%s), which the format cannot describe yet" % key)
    x = [float(v) for v in re.split(r"[;,\s]+", weights.strip()) if v]
    if len(x) != SPACES[space] + 1:
        raise FileError("The model has %d weights, not one per dimension of the space and an intercept" % len(x))
    model = {"format": FORMAT, "name": name, "space": space, "intercept": x[0], "weights": x[1:]}
    if description:
        model["description"] = description
    vectors = space_vectors(space, EXPORT_REFERENCES)
    m = {"onnx": None, "intercept": x[0], "weights": x[1:], "logistic": False}
    model["reference"] = [{"text": t, "prediction": apply(m, v)} for t, v in zip(EXPORT_REFERENCES, vectors) if v is not None]
    training = {"software": "SemanticExcel", "algorithm": "multiple linear regression on the dimensions of the space"}
    for key in ("n", "r", "p"):
        v = value(key)
        try:
            training[{"n": "n", "r": "cross-validated r", "p": "p"}[key]] = float(v)
        except (TypeError, ValueError):
            pass
    model["training"] = training
    return model


def main():
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        if command == "validate" and len(sys.argv) == 4:
            result = validate(sys.argv[2])
            out = sys.argv[3]
        elif command == "predict" and len(sys.argv) == 5:
            with open(sys.argv[3], encoding="utf-8") as f:
                texts = json.load(f)
            if not isinstance(texts, list) or not all(isinstance(t, str) for t in texts):
                raise FileError("The texts file must be a JSON list of texts")
            result = {"ok": True, "predictions": predict(sys.argv[2], texts)}
            out = sys.argv[4]
        elif command == "export" and len(sys.argv) == 7:
            result = export_semanticexcel(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
            out = sys.argv[6]
        else:
            sys.exit(__doc__)
    except FileError as error:
        result = {"ok": False, "message": str(error)}
        out = sys.argv[3] if command == "validate" else sys.argv[-1]
    with open(out, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=1)
    print(result["message"] if "message" in result else "Done")


if __name__ == "__main__":
    main()
