"""Compute predictions of Semantic Measure Model files for SemanticExcel documents.

The web server calls this service when a document uses a model file under Predict.
It keeps the last language models it used in memory, so that each text takes a
fraction of a second instead of the time it takes to load a model. It listens on
127.0.0.1 only and is run by systemd as semantic-model.service, in /opt/hf-venv.

  POST /predict  {"model": "<the model file as text>", "texts": ["...", ...]}
  answer         {"ok": true, "predictions": [...]}  or  {"ok": false, "message": "..."}
  POST /export   {"space": "spaceEnglish", "id": "_model", "name": "...", "description": "..."}
  answer         {"ok": true, "model": {a model file for a model trained in SemanticExcel}}
"""
import collections
import json
import os
import sys
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import semantic_model  # noqa: E402

PORT = 8765
MAX_LANGUAGE_MODELS = 2
MAX_TEXTS = 1000
MAX_BODY_BYTES = 8 * 1024 * 1024

loaded = collections.OrderedDict()
lock = threading.Lock()


def language_model(emb):
    if "space" in emb:
        return semantic_model.load_embedding(emb)
    key = (emb["model"], emb.get("revision"))
    if key in loaded:
        loaded.move_to_end(key)
    else:
        loaded[key] = semantic_model.load_language_model(*key)
        while len(loaded) > MAX_LANGUAGE_MODELS:
            loaded.popitem(last=False)
    return loaded[key]


def answer(body):
    request = json.loads(body.decode("utf-8"))
    texts = request.get("texts")
    if not isinstance(texts, list) or not all(isinstance(t, str) for t in texts) or len(texts) > MAX_TEXTS:
        raise semantic_model.FileError("texts must be a list of at most %d texts" % MAX_TEXTS)
    m = semantic_model.parse_model(request.get("model", ""))
    texts = [t[:semantic_model.MAX_TEXT_CHARS] for t in texts]
    with lock:
        return semantic_model.predict_loaded(m, language_model(m["embedding"]), texts)


def export(body):
    request = json.loads(body.decode("utf-8"))
    return semantic_model.export_semanticexcel(str(request.get("space", "")), str(request.get("id", "")),
                                               str(request.get("name", "")), str(request.get("description", "")))


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path not in ("/predict", "/export"):
            self.send_error(404)
            return
        length = int(self.headers.get("Content-Length") or 0)
        if length > MAX_BODY_BYTES:
            self.send_error(413)
            return
        try:
            body = self.rfile.read(length)
            if self.path == "/export":
                result = {"ok": True, "model": export(body)}
            else:
                result = {"ok": True, "predictions": answer(body)}
        except semantic_model.FileError as error:
            result = {"ok": False, "message": str(error)}
        except Exception as error:
            result = {"ok": False, "message": "The prediction failed on the server (%s)" % type(error).__name__}
        data = json.dumps(result).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
