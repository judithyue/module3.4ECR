FROM python:3.10-slim

WORKDIR /app

# 1. Clear Debian OS vulnerabilities
RUN apt-get update && apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

# 2. THE FIX: Physically remove the old, vulnerable system packages 
# that are causing the duplicate version detection in Trivy.
RUN rm -rf /usr/local/lib/python3.10/site-packages/pip* && \
    rm -rf /usr/local/lib/python3.10/site-packages/setuptools* && \
    rm -rf /usr/local/lib/python3.10/site-packages/wheel*

# 3. Reinstall only the SECURE versions from scratch
RUN python -m ensurepip && \
    python -m pip install --no-cache-dir --upgrade pip==24.0 setuptools==79.0.1 wheel==0.46.2

# 4. Copy and install your app requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of the app
COPY . .

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["app.py"]