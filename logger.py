#!/usr/bin/env python3

import argparse
import logging
import sys


def easy_logger(name: str, level_name: str) -> logging.Logger:
    """
    Setup initial logger and return it.
    This function exists to ensure loggers in other python scripts can match

    Args:
        name: Logger name
        level_name: loglevel to be set, levels are NOTSET, DEBUG, INFO, WARNING, ERROR, CRITICAL

    Returns:
        The Logger object

    """
    # Get initial logger
    logger = logging.getLogger(name.strip())

    # Configure initial logger
    logging.basicConfig(
        format="%(asctime)s.%(msecs)03d - %(name)s - %(levelname)s - %(message)s",
        datefmt="%I:%M:%S",
        level=logging.DEBUG,
    )

    # Set logging level
    level = getattr(logging, level_name)
    logger.setLevel(level)

    return logger


def logger_external(logger: logging.Logger) -> logging.Logger:
    logger.propagate = False
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        fmt="%(asctime)s.%(msecs)03d - %(name)s - EXTERNAL - %(message)s",
        datefmt="%I:%M:%S",
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger


def main():
    log_level_names = ["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n",
        "--name",
        action="store",
        help="Name for logger and logfile",
        required=True,
    )
    parser.add_argument(
        "-l",
        "--level",
        action="store",
        help="Log level to set; default is INFO",
        default="INFO",
        choices=log_level_names,
    )
    messages = parser.add_mutually_exclusive_group(required=True)
    messages.add_argument(
        "-x",
        "--external",
        action="store_true",
        help="Log external message. This always prints.",
    )
    messages.add_argument(
        "-d", "--debug", action="store_true", help="Log debug message"
    )
    messages.add_argument("-i", "--info", action="store_true", help="Log info message")
    messages.add_argument(
        "-w", "--warning", action="store_true", help="Log warning message"
    )
    messages.add_argument(
        "-e", "--error", action="store_true", help="Log error message"
    )
    messages.add_argument(
        "-c", "--critical", action="store_true", help="Log critical message"
    )
    messages.add_argument("-s", "--newline", action="store_true", help="Print newline")
    parser.add_argument("text", nargs="*")
    args = parser.parse_args()

    # Get logger
    logger = easy_logger(name=args.name.strip(), level_name=args.level)

    try:
        # Log message (or print newline)
        text = " ".join(args.text).strip()
        if args.newline:
            print("")
        elif text:
            logger_function = None
            if args.external:
                logger = logger_external(logger)
                logger_function = logger.info
            elif args.debug:
                logger_function = logger.debug
            elif args.info:
                logger_function = logger.info
            elif args.warning:
                logger_function = logger.warning
            elif args.error:
                logger_function = logger.error
            elif args.critical:
                logger_function = logger.critical
            if text == "-":
                for line in iter(sys.stdin.readline, ""):
                    logger_function(line.strip())
            else:
                logger_function(text)
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
