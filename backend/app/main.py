import time

from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

from app.api.milestones import router as milestones_router
from app.api.projects import router as projects_router
from app.core.config import settings
from app.core.metrics import HTTP_REQUEST_DURATION_SECONDS, HTTP_REQUESTS_TOTAL
from app.db.session import create_db_and_tables


app = FastAPI(title=settings.app_name, version=settings.app_version)

allowed_origins = [
    origin.strip()
    for origin in settings.frontend_origin.split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    if request.url.path == "/metrics":
        return await call_next(request)

    start = time.perf_counter()
    response = await call_next(request)

    # Use the route template (/projects/{project_id}), not the raw path,
    # so each project id doesn't create a new time series
    route = request.scope.get("route")
    labels = [request.method, route.path if route else "unmatched", str(response.status_code)]
    HTTP_REQUESTS_TOTAL.labels(*labels).inc()
    HTTP_REQUEST_DURATION_SECONDS.labels(*labels).observe(time.perf_counter() - start)
    return response


@app.on_event("startup")
def on_startup() -> None:
    create_db_and_tables()


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/metrics", include_in_schema=False)
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


app.include_router(projects_router)
app.include_router(milestones_router)
