#!/usr/bin/python3
import argparse
from glob import glob
from os import system
from os.path import expanduser
from random import randint
from time import sleep

PATH = expanduser("~/Изображения/Обои")
INDEX_FILE = "/tmp/wallpaper"
SECOND_SWITCH = 60


def set_index(index: int):
    with open(INDEX_FILE, "w") as file:
        file.write(str(index))


def get_index() -> int:
    with open("/tmp/wallpaper", "r") as file:
        return int(file.readline().strip())


def set_wallpaper(file_name: str):
    system(
        f"gsettings set org.gnome.desktop.background picture-uri file:///{file_name}"
    )


def main():
    parser = argparse.ArgumentParser(description="A simple CLI example with flags.")
    parser.add_argument("-n", "--next", action="store_true", help="Set next wallpaper")
    parser.add_argument(
        "-p", "--previous", action="store_true", help="Set previous wallpaper"
    )
    args = parser.parse_args()

    files = glob(PATH + "/*")
    files.sort()
    current_index: int = randint(0, len(files))
    iter_count: int = 0

    if args.next:
        next = get_index() + 1
        set_index(next if next <= len(files) - 1 else 0)
        return

    if args.previous:
        prev = get_index() - 1
        set_index(prev if prev >= 0 else len(files) - 1)
        return

    set_index(randint(0, len(files)))

    while True:
        sleep(1)

        if iter_count == SECOND_SWITCH:
            set_index(current_index + 1)
            iter_count = 0

        number = get_index()
        if number != current_index:
            current_index = number
            set_wallpaper(files[current_index])
        iter_count = iter_count + 1


if __name__ == "__main__":
    main()