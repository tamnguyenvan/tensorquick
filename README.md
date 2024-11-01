
<div style="display: flex; align-items: center; justify-content: center; margin-bottom: 50px;">
  <img src="./tensorquick/resources/icons/app-icon.svg" alt="Tensor Quick" width="250"/>
</div>


# Tensor Quick - AI Model Inference and Training Made Easy

Tensor Quick is a free, open-source, and multi-platform desktop application that helps you train and use AI models easily. It has a minimalist graphical interface, so you can use AI without technical skills.

## Table of Contents
- [Key Features](#key-features)
- [Installation](#installation)
  - [Installing Conda](#installing-conda)
  - [Installing Tensor Quick](#installing-tensor-quick)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Key Features

- **Multi-Platform Support**: Tensor Quick is available for Windows, macOS, and Linux, ensuring that users from various operating systems can benefit from its capabilities.
- **Intuitive GUI**: The application's user-friendly interface makes it easy for users to perform model inference and training tasks, even with little or no prior experience.
- **Cloud/GPU Provider Integration**: Tensor Quick supports integration with cloud and GPU providers, allowing users to leverage powerful computing resources for their AI workflows. Currently, the application supports the [Modal](https://modal.com/) provider, which offers $30 in free monthly credits for users with a GitHub account.
- **Open-Source**: Tensor Quick is an open-source project, allowing the community to contribute, customize, and extend its functionality.

## Installation

Tensor Quick can be installed using pip, the Python package installer. The recommended approach is to use the Conda package manager, which simplifies the installation process and manages dependencies.

### Installing Conda

1. Download the Conda installer for your operating system from the [official Conda website](https://docs.conda.io/en/latest/miniconda.html).
2. Run the installer and follow the on-screen instructions to complete the installation.
3. Open a terminal or command prompt and verify the installation by running `conda --version`.

### Installing Tensor Quick

1. Create a new Conda environment:
- On Windows: Open "Anaconda Prompt" from the Start menu to execute Conda commands.
- On macOS or Linux: Open a Terminal window to run Conda commands.

```bash
conda create -n tensorquick python=3.9 -y
```
2. Activate the Tensor Quick environment:
```bash
conda activate tensorquick
```
3. Install Tensor Quick using pip:
```bash
pip install tensorquick
```

## Usage

After installing Tensor Quick, you'll need to connect to the Modal cloud provider. This is a one-time setup process:

1. Open a terminal or Anaconda command prompt and activate the Tensor Quick Conda environment:
```bash
conda activate tensorquick
```

2. Run the modal setup command to connect Tensor Quick to the Modal cloud provide
```bash
modal setup
```

3. Launch the Tensor Quick application:
```bash
tensorquick
```

4. Create a Desktop Shortcut for Quick Access (Optional):
To quickly access Tensor Quick from your desktop, you can create a shortcut from within the application itself. Follow these steps:

- Open Tensor Quick by running the tensorquick command.
- Once the application is open, click on the settings (gear icon) in the top-right corner.
- Select Create Shortcut from the settings menu.

The Tensor Quick graphical user interface (GUI) will now open, allowing you to perform AI model inference and training tasks. Remember that you need to have the Tensor Quick Conda environment activated before running the tensorquick command.
For detailed usage instructions and documentation, please refer to the Tensor Quick User Guide.

## License

Tensor Quick is licensed under the [Apache License 2.0](https://github.com/your-username/tensorquick/blob/main/LICENSE).

## Support

If you encounter any issues or have questions about Tensor Quick, please feel free to reach out to us through the [project's issue tracker](https://github.com/tamnguyenvan/tensorquick/issues).