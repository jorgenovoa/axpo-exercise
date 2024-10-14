# stage builder
FROM python:3.12.7-slim AS builder

WORKDIR /workspace
  
COPY ./src . 
# install python packages in the user´s home(flag -e) to avoid permission issues when not running as root
RUN pip3 install --user --no-cache-dir -e .

# stage runner
FROM alpine:3 AS runner

RUN apk add python3=3.12.7-r0

WORKDIR /workspace

# Create user apiuser to run the applicacion 
RUN adduser -D apiuser

# Copy the python dependencies from the builder image and set the PATH
COPY  --chown=apiuser ./src .
COPY --chown=apiuser --from=builder /root/.local /home/apiuser/.local
ENV PATH=/home/apiuser/.local/bin:$PATH

USER apiuser


EXPOSE 5000
ENTRYPOINT ["python3","run.py"]
