FROM postgres:16-alpine
LABEL maintainer="KenanRicky <kaburaricky@gmail.com>"

# The password is NOT set here. It comes from the .env file at runtime.
ENV POSTGRES_DB=faraja POSTGRES_USER=postgres

# Runs once, the first time the database starts
COPY init.sql /docker-entrypoint-initdb.d/

# gosu is only needed when starting as root; we start as postgres, so remove it
# (it was flagged CRITICAL by Trivy: CVE-2025-68121)
RUN rm -f /usr/local/bin/gosu
USER postgres
EXPOSE 5432
