FROM postgres:16-alpine

# Environment variables for default database creation
ENV POSTGRES_DB=appdb
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=secret

# Copy any initialization scripts or SQL dumps into the entrypoint folder.
# Any .sql or .sh files placed here will run automatically on the first container startup.
COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432