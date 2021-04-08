from typing import Optional

import requests

from app.utils import state_is_valid
from client.config import Config
from client.exceptions import StateValidationException


class Client:
    def __init__(self, config: Config) -> None:
        self.config = config

    def update_state(
        self, filename: str, state: str, error_info: Optional[str] = None
    ) -> requests.Response:
        if not state_is_valid(state):
            raise StateValidationException(state)
        payload = {"state": state}
        if error_info:
            payload["error_info"] = error_info
        return requests.patch(self._update_url(filename), json=payload)

    def _update_url(self, filename: str) -> str:
        return f"{self.config.URL}/v1/state/{filename}"
