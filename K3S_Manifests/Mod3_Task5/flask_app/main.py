from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello():
    return 'Hello, World!'
K3S_Manifests/Mod3_Task5/flask_app/main.py
