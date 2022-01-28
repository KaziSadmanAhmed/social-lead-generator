from enum import Enum


class HealthCheckStatus(Enum):
    healthy = "HEALTHY"
    unhealthy = "UNHEALTHY"
