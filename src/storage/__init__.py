from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics

from storage.bucket import bucket_blueprint

app = Flask(__name__, static_url_path="", static_folder="../static")
app.config.from_object(__name__)
app.register_blueprint(bucket_blueprint, url_prefix="/api")

metrics = PrometheusMetrics(app)
# static information as metric
metrics.info('app_info', 'Application info', version='1.0.3')