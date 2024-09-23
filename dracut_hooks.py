#!/usr/bin/env python3

import argparse
import logging
import os
import re
import shutil
import subprocess
import sys
import textwrap
from pathlib import Path

THIS_FILE = Path(sys.argv[0]).resolve()
SCRIPT_NAME = THIS_FILE.name
LOGGER = logging.getLogger(SCRIPT_NAME)
logging.basicConfig(
    format="%(asctime)s.%(msecs)03d - %(name)s - %(levelname)s - %(message)s",
    datefmt="%I:%M:%S",
    level=logging.INFO,
)


def dracut_hooks(action="install", pacman_hooks_dir=Path("/etc/pacman.d/hooks")):
    dracut_install_hook = pacman_hooks_dir.joinpath("90-dracut-install.hook")
    dracut_remove_hook = pacman_hooks_dir.joinpath("60-dracut-remove.hook")

    match action:
        case "install":
            pacman_hooks_dir.mkdir(mode=755, exist_ok=True)

            install_hook_contents = textwrap.dedent(
                """
            [Trigger]
            Type = Path
            Operation = Install
            Operation = Upgrade
            Target = usr/lib/modules/*/pkgbase

            [Action]
            Description = Updating initramfs (dracut)
            When = PostTransaction
            Exec = /usr/local/bin/{} -a install --stdin
            NeedsTargets
            """.format(SCRIPT_NAME)
            )

            remove_hook_contents = textwrap.dedent(
                """
            [Trigger]
            Type = Path
            Operation = Remove
            Target = usr/lib/modules/*/pkgbase

            [Action]
            Description = Removing initramfs (dracut)
            When = PreTransaction
            Exec = /usr/local/bin/{} -a remove --stdin
            NeedsTargets
            """.format(SCRIPT_NAME)
            )

            with open(dracut_install_hook, "w") as install_hook:
                LOGGER.info("Writing {}".format(dracut_install_hook))
                install_hook.write(install_hook_contents)
            shutil.chown(dracut_install_hook, user="root", group="root")
            dracut_install_hook.chmod(0o500)

            with open(dracut_remove_hook, "w") as remove_hook:
                LOGGER.info("Writing {}".format(dracut_remove_hook))
                remove_hook.write(remove_hook_contents)
            shutil.chown(dracut_remove_hook, user="root", group="root")
            dracut_remove_hook.chmod(0o500)

        case "remove":
            dracut_install_hook.unlink(missing_ok=True)
            LOGGER.info("Removed {}".format(dracut_install_hook))
            dracut_remove_hook.unlink(missing_ok=True)
            LOGGER.info("Removed {}".format(dracut_remove_hook))


def execute_dracut(
    line,
    action="install",
    generate_fallback=True,
    args=["--force", "--no-hostonly-cmdline"],
):
    pattern = "usr/lib/modules/(.*)/pkgbase"
    match = re.match(pattern, line)

    pkgbase = Path("/{}".format(match.group(0)))

    kernel_version = match.group(1)
    kernel_name = pkgbase.read_text().strip()

    initramfs = Path("/boot/initramfs-{}.img".format(kernel_name))
    fallback_initramfs = Path("/boot/initramfs-{}-fallback.img".format(kernel_name))
    kernel_destination = Path("/boot/vmlinuz-{}".format(kernel_name))
    kernel_file = Path("/usr/lib/modules/{}/vmlinuz".format(kernel_version))
    dracut = Path(shutil.which("dracut"))

    match action:
        case "install":
            shutil.copy(kernel_file, kernel_destination)
            shutil.chown(kernel_destination, user="root", group="root")
            kernel_destination.chmod(0o444)
            LOGGER.info("Copied kernel as {}".format(kernel_destination))

            commands = []

            cmd = []
            cmd += [dracut.as_posix()]
            cmd += args
            cmd += ["--hostonly"]
            cmd += [initramfs.as_posix()]
            cmd += ["--kver", kernel_version]
            commands += [cmd]

            if generate_fallback:
                fb_cmd = []
                fb_cmd += [dracut.as_posix()]
                fb_cmd += args
                fb_cmd += ["--no-hostonly"]
                fb_cmd += [fallback_initramfs.as_posix()]
                fb_cmd += ["--kver", kernel_version]
                commands += [fb_cmd]

            for command in commands:
                LOGGER.info("Executing: {}".format(" ".join(command)))
                with subprocess.Popen(
                    command,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                ) as p:
                    for line in iter(p.stderr.readline, ""):
                        line = line.strip()
                        if line:
                            old_name = LOGGER.name
                            LOGGER.name = "dracut"
                            LOGGER.info(line)
                            LOGGER.name = old_name
            return True

        case "remove":
            for _file in (initramfs, fallback_initramfs, kernel_destination):
                _file.unlink(missing_ok=True)
                LOGGER.info("Removed {}".format(_file))
            return True

    return False


def setup(install_directory=Path("/usr/local/bin")):
    installed_script = install_directory.joinpath(SCRIPT_NAME)

    try:
        shutil.copy(THIS_FILE, installed_script)
        LOGGER.info("Installed script as {}".format(installed_script))
    except shutil.SameFileError:
        return

    shutil.chown(installed_script, user="root", group="root")
    installed_script.chmod(0o500)
    LOGGER.warning("Please ensure {} is in system PATH".format(install_directory))


def unsetup(install_directory=Path("/usr/local/bin")):
    installed_script = install_directory.joinpath(SCRIPT_NAME)
    installed_script.unlink(missing_ok=True)
    LOGGER.info("Removed {}".format(installed_script))


if __name__ == "__main__":
    epilog = """
    E.g. To install script and generate pacman hooks
    sudo {script} --setup
    sudo {script} -a install-hook
    """.format(script=THIS_FILE)

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter, epilog=epilog
    )
    parser.add_argument("--setup", action="store_true", help="install this script")
    parser.add_argument("--unsetup", action="store_true", help="remove this script")
    parser.add_argument(
        "--setup-directory",
        action="store",
        type=Path,
        help="set the directory for setup and unsetup",
        default=Path("/usr/local/bin"),
    )
    parser.add_argument(
        "-a",
        "--action",
        action="store",
        choices=("install", "remove", "install-hook", "remove-hook"),
        help="install generates initramfs via dracut; install-hook adds pacman hooks; remove actions delete files added by install actions",
    )
    parser.add_argument(
        "--line",
        action="append",
        type=list,
        help='a line to be evaulated for install or remove actions ; e.g. "usr/lib/modules/<kernel>/pkgbase"',
    )
    parser.add_argument(
        "--stdin",
        action="store_true",
        help="flag to read stdin; for use with pacman hook(s)",
    )

    args = parser.parse_args()

    if os.geteuid() != 0:
        LOGGER.error("Run this script as root!")
        sys.exit(1)

    lines = []
    if args.line:
        lines += args.line
    if args.stdin:
        for line in sys.stdin.readlines():
            lines += [line.strip()]

    if args.setup:
        setup(args.setup_directory)
    elif args.unsetup:
        unsetup(args.setup_directory)
    else:
        match args.action:
            case "install":
                for line in lines:
                    execute_dracut(line, "install", generate_fallback=True)
            case "remove":
                for line in lines:
                    execute_dracut(line, "remove")
            case "install-hook":
                dracut_hooks(action="install")
            case "remove-hook":
                dracut_hooks(action="remove")
