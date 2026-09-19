FROM python:3.10-slim

# Evita arquivos .pyc e garante envio direto dos logs ao stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

# Cria usuário não-root para execução segura do contêiner
RUN useradd -m -u 1001 appuser

# Copia dependências e instala
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código com propriedade para appuser
COPY --chown=appuser:appuser . .

# Coleta arquivos estáticos para produção usando WhiteNoise
RUN SECRET_KEY=build-dummy-key python manage.py collectstatic --noinput && \
    chown -R appuser:appuser /app

# Alterna para o usuário sem privilégios
USER appuser

EXPOSE 8000

# Executa servidor de produção Gunicorn com workers
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "mysite.wsgi:application"]
