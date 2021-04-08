import sys

from setuptools import setup

assert sys.version_info >= (3, 7, 0), "blaise_dds requires Python 3.7+"
from pathlib import Path  # noqa E402

CURRENT_DIR = Path(__file__).parent
sys.path.insert(0, str(CURRENT_DIR))  # for setuptools.build_meta

setup(
    name="blaise_dds",
    description="A python library for interacting with the blaise data-delivery-status service",  # noqa: E501
    url="https://github.com/ONSdigital/blaise-data-delivery-status",
    license="MIT",
    packages=["client"],
    package_dir={"": "."},
    python_requires=">=3.6",
    install_requires=["requests>=2.25.1", "pytz>=2021.1"],
    test_suite="tests/client",
    classifiers=[
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3 :: Only",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
)
