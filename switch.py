from enum import Enum
import subprocess
import time
import os
from logging import log, debug


class HostSystem(Enum):
    HOME = 1
    DARWIN = 2
    NIXOS = 3


# class UnsupportedSystemException(Exception):
#     def __str__(self):
#         system = self.args[0]
#         return f"Unspported System: {system}"
#
#     def what(self):
#         print(self)


def system_menu() -> HostSystem:
    OPTIONS = ("Home", "Darwin", "NixOS", "Quit")
    while True:
        print()
        for i, system in enumerate(OPTIONS):
            print(f"{i+1}: {system}")
        in_val = int(input("Choose System: "))
        if in_val < 1 or in_val > len(OPTIONS):
            print("Invalid Input")
            continue

        if in_val == 1:
            return HostSystem.HOME
        if in_val == 2:
            return HostSystem.DARWIN
        if in_val == 3:
            return HostSystem.NIXOS
        else:
            exit(0)


def build(build_cmd: str) -> int:
    print("Starting building the system...")
    ret = subprocess.run(["nix", "run", build_cmd, "build", "--",
                          "--flake", ".#default", "--show-trace"], capture_output=True)
    return ret.returncode


def commit():
    print("Making a commit...")
    now = time.strftime("%Y-%m-%d %H-%M-%S")
    commit_msg = f"[{now}] Update System Configuration"
    subprocess.run(["git", "commit", "-am", commit_msg])


def switch(switch_cmd: list):
    print("Switching system...")
    ret = subprocess.run(["nix", "run", *switch_cmd, "build", "--",
                          "--flake", ".#default", "--show-trace"], capture_output=True)


def main():
    current_system = system_menu()
    debug(f"Current System: ${current_system}")
    build_cmd = ""
    switch_cmd = ""
    match current_system:
        case HostSystem.HOME:
            build_cmd = "home-manager/master"
            switch_cmd = ["result/bin/home-manager-generation"]
        case HostSystem.DARWIN:
            build_cmd = "nix-darwin"
            switch_cmd = ["result/bin/sw/darwin-rebuild", "--flake", "."]
    debug("Build Command: ${build_cmd}")
    debug("Switch Command: ${switch_cmd}")
    ret = build(build_cmd)
    debug(f"Build return code: {ret}")

    if ret != 0:
        return

    commit()
    switch(switch_cmd)


if __name__ == "__main__":
    main()
