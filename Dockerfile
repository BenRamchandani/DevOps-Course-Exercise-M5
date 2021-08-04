# Use official Python base image
FROM python:3.8-slim-buster as base

ENV APP_INSTALL=/app
ENV POETRY_HOME=/poetry
ENV PATH=${POETRY_HOME}/bin:${PATH}
ENV PYTHONPATH=${APP_INSTALL}

# Install curl
RUN apt-get update && apt-get install curl -y

# Install poetry
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

# Install project dependencies
WORKDIR ${APP_INSTALL}
COPY poetry.lock pyproject.toml poetry.toml ./

# Install production dependencies
RUN poetry config virtualenvs.create false --local && poetry install --no-dev --no-root

####################################
# Production Image
FROM base as production

ENV FLASK_ENV=production

# Copy application code
COPY todo_app todo_app

# Define entrypoint and default command
ENTRYPOINT ["poetry", "run", "gunicorn", "todo_app.app:create_app()"]
CMD ["--bind", "0.0.0.0:80"]

EXPOSE 80


####################################
# Local Development Image
FROM base as development

ENV FLASK_ENV=development

# Define entrypoint and default command
ENTRYPOINT ["poetry", "run", "flask", "run"]
CMD ["--host", "0.0.0.0", "--port", "80"]

EXPOSE 80
