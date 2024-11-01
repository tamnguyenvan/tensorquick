from setuptools import setup, find_packages
import sys
import os

if sys.version_info < (3, 9):
    sys.exit('Python < 3.9 is not supported')

def read_requirements():
    """Read requirements.txt file and return list of requirements"""
    requirements_file = os.path.join(os.path.dirname(__file__), 'requirements.txt')
    try:
        with open(requirements_file) as f:
            requirements = [
                line.strip()
                for line in f
                if line.strip() and not line.startswith('#')
            ]
        return requirements
    except FileNotFoundError:
        return []

def read_readme():
    """Read README file"""
    try:
        with open('README.md', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return ''

# Platform-specific dependencies
windows_requires = ['pywin32>=225'] if sys.platform == 'win32' else []

setup(
    name="tensorquick",
    version="0.1.0",
    packages=find_packages(exclude=['tests*', 'docs*']),
    include_package_data=True,

    # Entry points cho console script
    entry_points={
        'console_scripts': [
            'tensorquick=tensorquick.main:main',
        ],
    },

    # Dependencies
    python_requires='>=3.9',
    install_requires=read_requirements(),
    extras_require={
        'win32': windows_requires,
        'dev': [
            'pytest>=6.0',
            'pytest-cov',
            'flake8',
            'black',
        ],
    },

    # Metadata
    author="Tam Nguyen",
    author_email="tamnv.work@gmail.com",
    description="Tensor Quick is a free, open-source, and multi-platform desktop application that helps you train and use AI models easily",
    long_description=read_readme(),
    long_description_content_type="text/markdown",
    keywords='ai, machine learning, deep learning, model training, inference',
    url="https://github.com/tamnguyenvan/tensorquick",
    project_urls={
        'Bug Reports': 'https://github.com/tamnguyenvan/tensorquick/issues',
        'Source': 'https://github.com/tamnguyenvan/tensorquick',
    },

    # Classifiers
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: Apache Software License",
        "Topic :: Software Development :: Build Tools",
        "Topic :: Scientific/Engineering :: Artificial Intelligence",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: 3 :: Only",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.9"
)