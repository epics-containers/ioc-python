"""Test IOC, run by tests/run-tests.sh: check the python stack in the image."""

import platform
import sys

import cothread  # noqa: F401
import matplotlib
import numpy
import scipy
from softioc import builder, softioc

print(f"args: {sys.argv[1:]}")
print(f"python {platform.python_version()} on {platform.machine()}")
print(f"numpy {numpy.__version__} scipy {scipy.__version__}")
print(f"matplotlib {matplotlib.__version__}")

builder.SetDeviceName("EXAMPLE")
builder.aOut("VALUE", initial_value=5.15)
builder.LoadDatabase()
softioc.iocInit()
softioc.dbgf("EXAMPLE:VALUE")
