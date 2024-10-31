from setuptools import setup, find_packages
import sys

def read_requirements():
    """Read requirements.txt file and return list of requirements"""
    with open('requirements.txt') as f:
        requirements = f.read().splitlines()
    return [r for r in requirements if r and not r.startswith('#')]

windows_requires = ['pywin32>=225'] if sys.platform == 'win32' else []

setup(
    name="tensorquick",
    version="0.1.0",
    packages=find_packages(),
    include_package_data=True,

    # Entry points cho console script
    entry_points={
        'console_scripts': [
            'tensorquick=tensorquick.main:main',
        ],
    },

    # Install requirements
    install_requires=read_requirements(),
    extras_require={
        ':sys_platform == "win32"': windows_requires,
    },

    # Metadata
    author="Tam Nguyen",
    author_email="tamnv.work@gmail.com",
    description="Tensor Quick is not just another deployment platform - it's a product crafted with dedication to make AI accessible and enjoyable.",
    long_description=open('README.md').read(),
    long_description_content_type="text/markdown",
    url="https://github.com/tamnguyenvan/tensorquick",
    classifiers=[
        "License :: OSI Approved :: Apache Software License",
        "Topic :: Software Development :: Build Tools",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: 3 :: Only",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)