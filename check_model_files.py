#!/usr/bin/env python3
"""Check model files uploaded to the SemanticExcel Library, and run test texts.

Cron runs this every minute. It takes the files that wait for a check, one at a
time, and runs semantic_model.py in the newer Python environment, which computes
the file's reference texts. The result goes back to the file in the Mongo
collection libraryModelFiles: status "passed" or "failed", and the report. A file
without "revision" that passes gets the version it was checked with written into
it, so that it gives the same results later even if the model changes on
huggingface.co.

It then computes the texts that users wrote in the test box of a passed file, from
the collection libraryModelTests.

The web server never runs the language model itself. It only stores the file and
the texts, which is why an upload or a test waits here.
"""
import fcntl
import json
import os
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
PYTHON = "/opt/hf-venv/bin/python"
CHECKER = os.path.join(HERE, "semantic_model.py")
TIMEOUT_SECONDS = 20 * 60
LOCK = "/tmp/check_model_files.lock"


def mongo(js):
    # The script goes in a file, since a model file can be longer than one command-line argument may be
    with tempfile.NamedTemporaryFile("w", suffix=".js", encoding="utf-8") as script:
        script.write(js)
        script.flush()
        out = subprocess.run(["mongo", "semantic", "--quiet", script.name],
                             stdout=subprocess.PIPE, check=True).stdout.decode("utf-8")
    return json.loads(out) if out.strip() else None


def next_file():
    """Claim the oldest waiting file, so that two runs never check the same one."""
    return mongo("""
        var f = db.libraryModelFiles.findAndModify({
            query: {status: 'waiting'}, sort: {created_at: 1},
            update: {$set: {status: 'checking', started_at: new Date()}}, new: true});
        print(f ? JSON.stringify({file_id: f.file_id, json: f.json}) : 'null');
    """)


def now():
    return time.strftime("%Y-%m-%d %H:%M:%S")


def finish(file_id, status, report, pinned_json):
    fields = {"status": status, "report": report, "checked_at": now()}
    if pinned_json is not None:
        fields["json"] = pinned_json
    mongo("db.libraryModelFiles.update({file_id: %s}, {$set: %s}); print('null')" % (json.dumps(file_id), json.dumps(fields)))


def pin_revision(text, revision):
    """The file with "revision" put right after "language_model", or None if it already has one."""
    m = json.loads(text)
    if m.get("revision") or not revision:
        return None
    pinned = {}
    for key, value in m.items():
        pinned[key] = value
        if key == "language_model":
            pinned["revision"] = revision
    return json.dumps(pinned, indent=1, ensure_ascii=False)


def run(args, work, out_path, what):
    env = dict(os.environ, LD_LIBRARY_PATH="/root/streamlit/openssl-1.1.1")
    try:
        subprocess.run([PYTHON, CHECKER] + args, env=env, cwd=work,
                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, timeout=TIMEOUT_SECONDS)
    except subprocess.TimeoutExpired:
        return {"ok": False, "message": "The %s took longer than 20 minutes and was stopped." % what}
    if not os.path.exists(out_path):
        return {"ok": False, "message": "The %s stopped with an error on the server. Please try again later." % what}
    with open(out_path, encoding="utf-8") as r:
        return json.load(r)


def check(f):
    with tempfile.TemporaryDirectory() as work:
        model_path = os.path.join(work, "model.json")
        report_path = os.path.join(work, "report.json")
        with open(model_path, "w", encoding="utf-8") as out:
            out.write(f["json"])
        return run(["validate", model_path, report_path], work, report_path, "check")


def next_test():
    return mongo("""
        var t = db.libraryModelTests.findAndModify({
            query: {status: 'waiting'}, sort: {created_at: 1},
            update: {$set: {status: 'running', started_at: new Date()}}, new: true});
        var f = t ? db.libraryModelFiles.findOne({file_id: t.file_id, status: 'passed'}) : null;
        print(t ? JSON.stringify({test_id: t.test_id, texts: t.texts, json: f ? f.json : null}) : 'null');
    """)


def run_test(t):
    if t["json"] is None:
        return {"ok": False, "message": "The model file is no longer available."}
    with tempfile.TemporaryDirectory() as work:
        model_path = os.path.join(work, "model.json")
        texts_path = os.path.join(work, "texts.json")
        out_path = os.path.join(work, "out.json")
        with open(model_path, "w", encoding="utf-8") as out:
            out.write(t["json"])
        with open(texts_path, "w", encoding="utf-8") as out:
            json.dump(t["texts"], out, ensure_ascii=False)
        return run(["predict", model_path, texts_path, out_path], work, out_path, "test")


def finish_test(test_id, result):
    fields = {"status": "done" if result.get("ok") else "failed", "finished_at": now(),
              "predictions": result.get("predictions", []), "message": result.get("message", "")}
    mongo("db.libraryModelTests.update({test_id: %s}, {$set: %s}); print('null')" % (json.dumps(test_id), json.dumps(fields)))


def main():
    with open(LOCK, "w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError:
            return  # the previous run is still checking
        # A file left in "checking" by a run that died is checked again
        stale = (TIMEOUT_SECONDS + 300) * 1000
        mongo("db.libraryModelFiles.update({status: 'checking', started_at: {$lt: new Date(Date.now() - %d)}},"
              " {$set: {status: 'waiting'}}, {multi: true});"
              " db.libraryModelTests.update({status: 'running', started_at: {$lt: new Date(Date.now() - %d)}},"
              " {$set: {status: 'waiting'}}, {multi: true}); print('null')" % (stale, stale))
        while True:
            f = next_file()
            if f is None:
                break
            report = check(f)
            passed = bool(report.get("ok"))
            pinned = pin_revision(f["json"], report.get("revision_used")) if passed else None
            if pinned is not None:
                report["revision_pinned"] = True
            finish(f["file_id"], "passed" if passed else "failed", report, pinned)
        while True:
            t = next_test()
            if t is None:
                return
            finish_test(t["test_id"], run_test(t))


if __name__ == "__main__":
    main()
