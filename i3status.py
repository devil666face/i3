from datetime import datetime
from time import sleep

while True:
    out = "".join(
        [
            datetime.now().strftime("%d%m%y %w %H%M%S"),
        ]
    )
    for emoji, number in zip(
        [
            "0️⃣",
            "1️⃣",
            "2️⃣",
            "3️⃣",
            "4️⃣",
            "5️⃣",
            "6️⃣",
            "7️⃣",
            "8️⃣",
            "9️⃣",
        ],
        ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
    ):
        out = out.replace(number, emoji)

    with open("/tmp/i3status", "w") as writer:
        writer.write(out)

    sleep(1)
