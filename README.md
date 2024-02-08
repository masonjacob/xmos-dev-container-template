# XMOS Docker Development Container - XTC Tools 15.2.1 & XCORE VOICE SDK
----------------------------------------------------------------
## Docker Dev Enviroment
This project is configured with a Docker multi-container environment to facilitate cross platform development. The environment is comprised of the following services:
- **xmos-dev**: contains XTC tools and the sln_voice repository, located in `/opt/xmos`, as well as a bind mount to the src folder and a shared volume `/shared`, located in `/home`.
- **gtkwave**: automatically runs the gtkwave application used to debug simulated signal outputs. the `/shared` volume is mounted in the top-level directory to make it easy to tranfer output files to the application.

### Prerequisites

The following must be installed before you can run the dev environment:
- Docker
- VS-Code & Dev Containers Extension
- WSL2 (Windows Only)
- winget (Windows Only, Windows Package Manager)
- USBIPD-WIN (Windows Only, installed with `winget install --interactive --exact dorssel.usbipd-win` in Powershell)

### Connecting the XTAG to the Dev Environment

#### Linux:
The xmos-dev container bind mounts `/dev/bus/usb`, so USB devices should be accessible in the xmos-dev container automatically. Run `lsusb` in the container to verify.

#### Windows:

To connect to an XTAG on a Windows host machine, the USB device must be tunneled into the container. 

1. Install USBIPD-WIN by running the following in Powershell:
```
winget install --interactive --exact dorssel.usbipd-win
```

2. Open a new WSL2 Terminal window and run the following:
```
sudo apt install linux-tools-generic hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip $(command -v ls /usr/lib/linux-tools/*/usbip | tail -n1) 20
```

3. Connect the XTAG to the computer using the provided USB cable. 

4. Run the Powershell `configure.ps1` script as administrator, located in `.\scripts\`. By default (no arguments passed) the script addes the UDEV rules to WSL if they do not exist, and attaches any XTAGs connected using USBIPD. To only attach or detach XTAG devices, run the script with `--attach` or `--detach` flags. Run the script with the `--help` flag to see all options.

4. To verify that the XTAG has been attached, you can run `usbipd wsl list`.

### Starting the Dev Environment

#### From VSCode (Recommended)

1. Open this repository in VSCode.

2. Using `Ctrl+Shift+P` to open the Command Palette, search and run `Dev Containers: Rebuild and Reopen in Container`

3. VSCode will now setup and run the development container, and then open a new editor window.

4. You can verify that the XTAG is visible in the dev container by running `xrun -l`

Congrats! You have a running dev enviroment and are ready to program and flash the XCORE platform.

#### Manually

The dev enviroment can be build and run with the following command:
```
docker-compose up -d
```

After all containers are built and deployed, open VS-Code and do the following:
- open the command palette using `CTRL+SHIFT+P`. 
- Search for and select `Dev Containers: Attach to Running Container...`. 
- select the running `xmos-dev` container from the dropdown list

VS-Code will now open a new window attached to the running xmos-dev container. Select the "Open Folder" to open the `/src` bind mount, located under `/home`. 


