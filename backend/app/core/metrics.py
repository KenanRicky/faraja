from prometheus_client import Counter, Gauge, Histogram
from sqlmodel import Session, func, select

from app.db.session import engine
from app.models.milestone import Milestone
from app.models.project import Project


HTTP_REQUESTS_TOTAL = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "route", "status_code"],
)

HTTP_REQUEST_DURATION_SECONDS = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "route", "status_code"],
    buckets=[0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
)


def count_rows(model):
    with Session(engine) as session:
        return session.exec(select(func.count()).select_from(model)).one()


# Business metrics, read from the database each time Prometheus scrapes
PROJECTS_TOTAL = Gauge("faraja_projects_total", "Projects in the database")
PROJECTS_TOTAL.set_function(lambda: count_rows(Project))

MILESTONES_TOTAL = Gauge("faraja_milestones_total", "Milestones in the database")
MILESTONES_TOTAL.set_function(lambda: count_rows(Milestone))
