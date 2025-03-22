import socket
from dataclasses import dataclass
from typing import Self


@dataclass
class GyverTwinkSettings:
    led_amount: int
    power: bool
    brightness: int
    auto_change_effect: bool
    random_effect: bool
    effect_change_period_minutes: int
    timer_enabled: bool
    timer_minutes: int

    @classmethod
    def from_udp(cls, packet: list[int]) -> Self:
        return cls(
            led_amount=packet[3] * 100 + packet[4],
            power=bool(packet[5]),
            brightness=packet[6],
            auto_change_effect=bool(packet[7]),
            random_effect=bool(packet[8]),
            effect_change_period_minutes=packet[9],
            timer_enabled=bool(packet[10]),
            timer_minutes=packet[11],
        )


class GyverTwinkUDP:
    """Небольшой АПИ-класс"""

    def __init__(self, ip: str, port: int) -> None:
        self.ip = ip
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def set_power(self, value: bool) -> None:
        """Вкл/Выкл гирлянды"""
        message = bytearray([71, 84, 2, 1, (1 if value else 0)])

        self.socket.sendto(message, (self.ip, self.port))

    def set_brightness(self, value: int) -> None:
        """Установить яркость (0-255)"""
        message = bytearray([71, 84, 2, 2, value])

        self.socket.sendto(message, (self.ip, self.port))

    def get_settings(self) -> GyverTwinkSettings:
        """Получить текущие настройки"""
        self.socket.sendto(bytearray([71, 84, 1]), (self.ip, self.port))
        message, _ = self.socket.recvfrom(1024)
        return GyverTwinkSettings.from_udp(list(message))
