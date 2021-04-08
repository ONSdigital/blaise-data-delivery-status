from app.utils import STATES


class StateValidationException(Exception):
    def __init__(self, state):
        self.state = state
        self.valid_states = ", ".join(STATES.keys())
        super().__init__(
            f"State '{self.state}' is invalid, valid states are [{self.valid_states}]"
        )
