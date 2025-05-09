from enum import Enum
import subprocess
import time
import os
import sys
from logging import debug, error, basicConfig, INFO

basicConfig(level=INFO)

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
        try:
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
                sys.exit(0)
        except ValueError:
            print("Please enter a valid number")


def shell_cmd(cmd: list) -> tuple[bool, str]:
    try:
        process = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        while True:
            output = process.stdout.readline()
            if output == "" and process.poll() is not None:
                break
            if output:
                print(output.strip())

        stderr = process.communicate()[1]
        if stderr:
            if "warning" in stderr:
                return (True, "")
            error(stderr)
            return (False, stderr)
        return (True, "")
    except Exception as e:
        error(f"Error executing command: {e}")
        return (False, str(e))


def build(build_cmd: str) -> tuple[bool, str]:
    print("Starting building the system...")
    return shell_cmd(["nix", "run", build_cmd, "build", "--", "--flake", ".#default"])


def commit() -> tuple[bool, str]:
    print("Making a commit...")
    now = time.strftime("%Y-%m-%d %H-%M-%S")
    commit_msg = f"[{now}] Update System Configuration"
    return shell_cmd(["git", "commit", "-am", commit_msg])


def switch(switch_cmd: list) -> bool:
    print("Switching system...")
    try:
        result = subprocess.run(["nix", "run", *switch_cmd, "build", "--",
                               "--flake", ".#default", "--show-trace"])
        return result.returncode == 0
    except Exception as e:
        error(f"Error during switch: {e}")
        return False


def main():
    current_system = system_menu()
    debug(f"Current System: {current_system}")
    
    build_cmd = ""
    switch_cmd = []
    
    match current_system:
        case HostSystem.HOME:
            build_cmd = "home-manager/master"
            switch_cmd = ["home-manager/master", "switch", "--flake", ".#default"]
        case HostSystem.DARWIN:
            build_cmd = "nix-darwin"
            switch_cmd = ["nix-darwin", "switch", "--flake", ".#rays-MacBook-Air"]
        case HostSystem.NIXOS:
            build_cmd = "nixos-rebuild"
            switch_cmd = ["nixos-rebuild", "switch", "--flake", ".#default"]
    
    debug(f"Build Command: {build_cmd}")
    debug(f"Switch Command: {switch_cmd}")
    
    status, err = build(build_cmd)
    if not status:
        error(f"Build failed: {err}")
        return

    status, err = commit()
    if not status:
        error(f"Commit failed: {err}")
        return

    if not switch(switch_cmd):
        error("Switch failed")
        return

    print("Done!")


if __name__ == "__main__":
    main()
