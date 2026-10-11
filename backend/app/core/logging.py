import logging
import re
import sys

SENSITIVE_PATTERN = re.compile(
    r"(password|secret|token|authorization|api[_-]?key|private[_-]?key|fcm)",
    re.IGNORECASE,
)


class RedactingFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        if isinstance(record.msg, str) and SENSITIVE_PATTERN.search(record.msg):
            record.msg = "[REDACTED log message]"
        return True


def configure_logging(level: str = "INFO") -> None:
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            handler.addFilter(RedactingFilter())
        root.setLevel(level.upper())
        return

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)s [%(name)s] %(message)s"))
    handler.addFilter(RedactingFilter())
    root.addHandler(handler)
    root.setLevel(level.upper())
    logging.getLogger("uvicorn.access").addFilter(RedactingFilter())
