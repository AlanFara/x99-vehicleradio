# 🚗 x99 Vehicle Radio for FiveM 🎶

Welcome to the **x99-vehicleradio** repository! This project provides a dynamic vehicle radio system for FiveM, enhancing your gaming experience with custom audio features. 

[![Download Latest Release](https://img.shields.io/badge/Download%20Latest%20Release-Click%20Here-blue)](https://github.com/AlanFara/x99-vehicleradio/releases)

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

- **Custom Audio Streaming**: Play your favorite music while driving.
- **Easy Setup**: Simple installation process to get you started quickly.
- **User-Friendly Interface**: Navigate through your audio options effortlessly.
- **Multi-Platform Support**: Works seamlessly across various devices.
- **Regular Updates**: Stay tuned for new features and improvements.

## Installation

To install the x99 Vehicle Radio, follow these steps:

1. **Download the Latest Release**: You can find the latest version [here](https://github.com/AlanFara/x99-vehicleradio/releases). Download the file and execute it.
   
2. **Extract the Files**: Unzip the downloaded file into your FiveM resources folder.

3. **Add to Server Config**: Open your `server.cfg` file and add the following line:
   ```
   start x99-vehicleradio
   ```

4. **Restart Your Server**: Ensure your server is restarted to apply the changes.

## Usage

Once installed, using the x99 Vehicle Radio is straightforward:

- **In-Game Commands**: Use the command `/radio` to open the radio interface.
- **Select Your Station**: Browse through available stations and select your favorite.
- **Volume Control**: Adjust the volume using the in-game settings.

## Configuration

You can customize the vehicle radio settings to suit your preferences:

- **Audio Sources**: Edit the configuration file to add or remove audio sources.
- **Station Names**: Change the names of the stations to personalize your experience.
- **Volume Levels**: Set default volume levels for different audio sources.

### Example Configuration

Here’s a sample configuration snippet:

```json
{
  "stations": [
    {
      "name": "Rock Hits",
      "url": "http://example.com/rockhits"
    },
    {
      "name": "Pop Classics",
      "url": "http://example.com/popclassics"
    }
  ],
  "defaultVolume": 75
}
```

## Contributing

We welcome contributions from the community! If you want to improve the x99 Vehicle Radio, please follow these steps:

1. **Fork the Repository**: Click on the fork button at the top right of the page.
2. **Create a Branch**: Use a descriptive name for your branch.
   ```
   git checkout -b feature/YourFeatureName
   ```
3. **Make Your Changes**: Implement your feature or fix a bug.
4. **Commit Your Changes**: Write a clear commit message.
   ```
   git commit -m "Add your message here"
   ```
5. **Push to Your Branch**: 
   ```
   git push origin feature/YourFeatureName
   ```
6. **Open a Pull Request**: Submit your changes for review.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries or support, feel free to reach out:

- **GitHub**: [AlanFara](https://github.com/AlanFara)
- **Email**: alan@example.com

---

Thank you for checking out the x99 Vehicle Radio! Enjoy your enhanced FiveM experience. Don't forget to download the latest version [here](https://github.com/AlanFara/x99-vehicleradio/releases) and get started!