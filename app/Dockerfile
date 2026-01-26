# Base Image - Build: python/slim-buster:fewer packages
FROM python:3.9.13-slim-buster AS builder

# Working directory
WORKDIR /app

# Copy dependencies from req
COPY requirements.txt .

# venv=python environment for dependencies needed in second build
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:#PATH"

# install them
RUN pip install --no-cache-dir -r requirements.txt


# Second Stage: excludes cache 
FROM python:3.9.13-slim-buster

WORKDIR /app

# non root user
RUN groupadd --system app && useradd --system --gid app --create-home app

# copies dependencies from build stage using the venv
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"


#copy files from local to /app
COPY . .

# non root user can still read+write app files 
RUN chown -R app:app /app

# runtime to non root
USER app

# port - doc only
EXPOSE 8080

# run time command
CMD [ "python3", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080" ]