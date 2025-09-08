#!/usr/bin/env python3

from time import time
from threading import Timer, Thread, RLock
from signal import pause
import logging
import sys

from gpiozero import RotaryEncoder, Button
import requests


SNAPCAST_CLIENT_ID = "{{ snapcast_remote_client_id }}"
SNAPCAST_HOST = "{{ snapcast_remote_host }}"
SNAPCAST_PORT = int("{{ snapcast_remote_port | default(1780) }}")
BUTTON_PIN = "{{ snapcast_remote_button_pin | default('BOARD8') }}"
ROTARY_ENCODER_PIN_A = "{{ snapcast_remote_rotary_encoder_pin_a | default('BOARD32') }}"
ROTARY_ENCODER_PIN_B = "{{ snapcast_remote_rotary_encoder_pin_b | default('BOARD36') }}"


logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
logger = logging.getLogger(__name__)


class SnapcastClient:
    def __init__(self, client_id: str, host: str, port: int = 1780):
        self.client_id = client_id
        self.base_url = f"http://{host}:{port}/jsonrpc"

        self.volume_lock = RLock()
        self.volume = 10
        self.last_volume_update = 0
        self._refresh_volume()

        self.group_lock = RLock()
        self.group = {"clients": []}
        self.last_group_update = 0
        self._refresh_group()

        self.sources_lock = RLock()
        self.sources = []
        self.last_sources_update = 0
        self._refresh_sources()

    def _send_request(self, method, params=None) -> dict | None:
        payload = {
            "jsonrpc": "2.0",
            "method": method,
            "id": 1,
        }
        if params:
            payload["params"] = params

        response = requests.post(
            self.base_url,
            json=payload,
            timeout=5,
        )
        response.raise_for_status()

        data = response.json()
        if "error" in data:
            logger.warning(
                f"error while making request.\nmethod: {method}\nparams: {params}\nresponse: {response}\ndata: {data}"
            )
            return None

        return data

    def _get_group(self) -> dict | None:
        response = self._send_request("Server.GetStatus")
        if response is None:
            return None
        for group in response["result"]["server"]["groups"]:
            for client in group["clients"]:
                if client["id"] == self.client_id:
                    return group
        return None

    def _get_client(self) -> dict | None:
        response = self._send_request("Server.GetStatus")
        if response is None:
            return None
        for group in response["result"]["server"]["groups"]:
            for client in group["clients"]:
                if client["id"] == self.client_id:
                    return client
        return None

    def _refresh_volume(self) -> None:
        if time() - self.last_volume_update <= 5:
            return
        logger.info("snapcast volume is stale, refreshing")
        with self.volume_lock:
            client = self._get_client()
            if client is None:
                return
            self.volume = client["config"]["volume"]["percent"]
            self.last_volume_update = time()

    def _refresh_group(self) -> None:
        if time() - self.last_group_update <= 300:
            return
        logger.info("snapcast group is stale, refreshing")
        with self.group_lock:
            group = self._get_group()
            if group is None:
                return
            self.group = group
            self.last_group_update = time()

    def _refresh_sources(self) -> None:
        if time() - self.last_sources_update <= 300:
            return
        logger.info("snapcast sources are stale, refreshing")
        with self.sources_lock:
            response = self._send_request("Server.GetStatus")
            if response is None:
                return
            streams = response["result"]["server"]["streams"]
            self.sources = [
                stream["id"]
                for stream in streams
                if stream["id"] not in ("test", "vide")
            ]
            self.last_sources_update = time()
        logger.info(f"sources are {self.sources}")

    def toggle_mute(self) -> None:
        logger.info("toggling snapcast mute")

        client = self._get_client()
        group = self._get_group()
        if client is None or group is None:
            return

        group_muted = group["muted"]
        client_muted = client["config"]["volume"]["muted"]
        muted = group_muted or client_muted

        new_muted = not muted
        logger.info(f"setting snapcast mute to {new_muted}")

        self._send_request(
            "Group.SetMute",
            {
                "id": group["id"],
                "mute": new_muted,
            },
        )
        for client in group["clients"]:
            self._send_request(
                "Client.SetVolume",
                {
                    "id": client["id"],
                    "volume": {
                        "muted": new_muted,
                    },
                },
            )

    def adjust_volume(self, delta: int) -> None:
        with self.volume_lock:
            logger.info(f"adjusting snapcast volume by {delta}")
            self._refresh_volume()
            self._refresh_group()

            new_volume = max(0, min(100, self.volume + delta))
            logger.info(f"setting new snapcast volume to {new_volume}")

            for client in self.group["clients"]:
                self._send_request(
                    "Client.SetVolume",
                    {
                        "id": client["id"],
                        "volume": {
                            "percent": new_volume,
                        },
                    },
                )
            self.volume = new_volume

    def cycle_source(self) -> None:
        with self.sources_lock:
            logger.info("cycling snapcast source")
            self._refresh_sources()

            if not self.sources:
                return

            group = self._get_group()
            if group is None:
                return
            current_source = group["stream_id"]
            try:
                current_source_index = self.sources.index(current_source)
            except ValueError:
                current_source_index = -1

            next_source = self.sources[(current_source_index + 1) % len(self.sources)]

            logger.info(f"setting snapcast source to '{next_source}'")
            self._send_request(
                "Group.SetStream",
                {
                    "id": group["id"],
                    "stream_id": next_source,
                },
            )


class ButtonHandler:
    def __init__(
        self,
        button_pin: str | int,
        rotary_encoder_pin_a: str | int,
        rotary_encoder_pin_b: str | int,
        snapcast_client: SnapcastClient,
    ):
        self.button = Button(
            button_pin,
            pull_up=True,
            bounce_time=0.02,
        )
        self.rotary_encoder = RotaryEncoder(
            a=rotary_encoder_pin_a,
            b=rotary_encoder_pin_b,
            wrap=False,
            max_steps=0,
        )
        self.snapcast_client = snapcast_client

        self.press_count = 0
        self.long_press_threshold = 1.0
        self.multi_press_timeout = 0.5
        self.timer = None
        self.press_start_time = 0

        self.button.when_pressed = self._on_press
        self.button.when_released = self._on_release

        self.rotary_encoder.when_rotated_clockwise = self._on_rotate_clockwise
        self.rotary_encoder.when_rotated_counter_clockwise = (
            self._on_rotate_counter_clockwise
        )

    def _on_press(self) -> None:
        self.press_start_time = time()
        logger.debug(f"button pressed at {self.press_start_time}")

    def _on_release(self) -> None:
        press_release_time = time()
        logger.debug(f"button released at {press_release_time}")
        press_duration = time() - self.press_start_time
        logger.debug(f"button pressed for {press_duration}")

        if press_duration >= self.long_press_threshold:
            logger.info("button long-pressed, TODO")
            # TODO: bluetooth
            self.press_count = 0
            if self.timer:
                self.timer.cancel()
            return

        self.press_count += 1
        logger.debug(
            f"button pressed {self.press_count} times so far, restarting timer"
        )

        if self.timer:
            self.timer.cancel()

        self.timer = Timer(self.multi_press_timeout, self._process_presses)
        self.timer.start()

    def _process_presses(self) -> None:
        logger.info(f"button pressed {self.press_count} times")
        if self.press_count == 1:
            logger.info("1 button press, toggling mute")
            Thread(target=self.snapcast_client.toggle_mute, daemon=True).start()
        elif self.press_count == 2:
            logger.info("2 button presses, cycling source")
            Thread(target=self.snapcast_client.cycle_source, daemon=True).start()
        else:
            logger.info(f"{self.press_count} button presses, ignoring")

        self.press_count = 0

    def _on_rotate_clockwise(self) -> None:
        logger.info("clockwise rotation, increasing volume")
        Thread(
            target=lambda: self.snapcast_client.adjust_volume(5), daemon=True
        ).start()

    def _on_rotate_counter_clockwise(self) -> None:
        logger.info("clockwise rotation, decreasing volume")
        Thread(
            target=lambda: self.snapcast_client.adjust_volume(-5), daemon=True
        ).start()


snapcast_client = SnapcastClient(SNAPCAST_CLIENT_ID, SNAPCAST_HOST, SNAPCAST_PORT)
button_handler = ButtonHandler(
    button_pin=BUTTON_PIN,
    rotary_encoder_pin_a=ROTARY_ENCODER_PIN_A,
    rotary_encoder_pin_b=ROTARY_ENCODER_PIN_B,
    snapcast_client=snapcast_client,
)

logger.info("Snapcast remote started")
pause()
