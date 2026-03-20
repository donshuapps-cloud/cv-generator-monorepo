FROM python:3.10-slim
# Instalar LaTeX
RUN apt-get update && apt-get install -y \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install -r requirements.txt
COPY backend/ .
COPY index.html /app/static/
COPY css/ /app/static/css/
COPY js/ /app/static/js/
COPY lib/ /app/static/lib/
COPY examples/ /app/static/examples/
EXPOSE 5000
CMD ["python", "server.py"]
