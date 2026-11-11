"""Compute the predictions of an ONNX model for text vectors.

semantic_model.py runs this in /opt/onnx-venv, because ONNX Runtime needs NumPy 1 and the
Hugging Face environment has NumPy 2. It reads {"onnx": base64 text, "vectors": [[...], ...]}
on stdin and writes {"ok": true, "predictions": [...]} or {"ok": false, "message": "..."}.
"""
import base64
import json
import sys


def main():
    request = json.load(sys.stdin)
    vectors = request["vectors"]
    try:
        import numpy
        import onnxruntime
        options = onnxruntime.SessionOptions()
        options.intra_op_num_threads = 1
        session = onnxruntime.InferenceSession(base64.b64decode(request["onnx"]), options, providers=["CPUExecutionProvider"])
    except Exception as error:
        return {"ok": False, "message": "The ONNX model could not be read (%s)" % type(error).__name__}
    inputs = session.get_inputs()
    if len(inputs) != 1:
        return {"ok": False, "message": "The ONNX model must have one input, the vector of a text"}
    shape = inputs[0].shape
    dim = len(vectors[0]) if vectors else 0
    if not shape or (isinstance(shape[-1], int) and shape[-1] != dim):
        return {"ok": False, "message": "The ONNX model takes vectors with %s dimensions, but the language model gives %d"
                % (shape[-1] if shape else "no", dim)}
    predictions = []
    try:
        for v in vectors:
            output = session.run(None, {inputs[0].name: numpy.array([v], dtype=numpy.float32)})[0]
            predictions.append(float(numpy.asarray(output).ravel()[0]))
    except Exception as error:
        return {"ok": False, "message": "The ONNX model failed on a text vector (%s)" % type(error).__name__}
    return {"ok": True, "predictions": predictions}


if __name__ == "__main__":
    json.dump(main(), sys.stdout)
