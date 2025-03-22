import os

from bottle import get, post, run

from twink_iot.twink import GyverTwinkUDP

twink = GyverTwinkUDP(
    ip=os.getenv("GYVERTWINK__IP", "192.168.1.36"),
    port=int(os.getenv("GYVERTWINK__PORT", 8888)),
)


@post("/gyvertwink/set-pwr/<pwr:int>")
def set_power(pwr: int) -> str:
    twink.set_power(bool(pwr))
    return "OK"


@post("/gyvertwink/set-brightness/<brightness:int>")
def set_brightness(brightness: int) -> str:
    twink.set_brightness(int(brightness * 2.55))
    return "OK"


@get("/gyvertwink/get-pwr")
def get_power() -> dict:
    config = twink.get_settings()
    return {"value": config.power}


def main() -> None:
    run(host="0.0.0.0", port=8083)


if __name__ == "__main__":
    main()
